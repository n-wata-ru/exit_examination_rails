import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "submit"]
  static values = { threadId: Number }

  connect() {
    console.log("Chat form controller connected, thread ID:", this.threadIdValue)
    
    // MutationObserverでトリガー要素を監視
    const messagesContainer = document.getElementById("messages")
    const observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        mutation.addedNodes.forEach((node) => {
          if (node.id === "trigger-sse") {
            const threadId = node.dataset.threadId
            console.log("SSE trigger detected for thread:", threadId)
            this.startSSE(threadId)
            node.remove() // トリガー要素を削除
          }
        })
      })
    })
    
    observer.observe(messagesContainer, { childList: true, subtree: true })
    this.observer = observer
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  showLoading() {
    // 入力フィールドをクリア
    this.inputTarget.value = ""
    
    // 送信ボタンを無効化
    this.submitTarget.disabled = true
    this.submitTarget.textContent = "送信中..."
    this.submitTarget.classList.add("opacity-50", "cursor-not-allowed")
  }

  startSSE(threadId) {
    console.log("Starting SSE for thread:", threadId)
    const messagesContainer = document.getElementById("messages")
    
    // AIメッセージの箱を作成
    const aiMessageDiv = document.createElement("div")
    aiMessageDiv.className = "mb-4 text-left"
    aiMessageDiv.id = "ai-message-streaming"
    
    const contentContainer = document.createElement("div")
    contentContainer.className = "inline-block max-w-md p-3 rounded-lg bg-white border border-gray-300"
    
    const contentElement = document.createElement("p")
    contentElement.className = "text-sm"
    contentElement.textContent = ""
    
    const loadingDiv = document.createElement("div")
    loadingDiv.className = "flex items-center gap-2 mt-2"
    loadingDiv.innerHTML = `
      <div class="animate-spin h-4 w-4 border-2 border-blue-500 rounded-full border-t-transparent"></div>
      <span class="text-xs text-gray-600">AIが考え中...</span>
    `
    
    contentContainer.appendChild(contentElement)
    contentContainer.appendChild(loadingDiv)
    aiMessageDiv.appendChild(contentContainer)
    messagesContainer.appendChild(aiMessageDiv)
    messagesContainer.scrollTop = messagesContainer.scrollHeight
    
    // SSE接続
    console.log("Creating EventSource:", `/chat_threads/${threadId}/stream`)
    const eventSource = new EventSource(`/chat_threads/${threadId}/stream`)
    
    // 要素を直接参照として保存
    this.currentContentElement = contentElement
    this.currentLoadingDiv = loadingDiv
    this.currentContentContainer = contentContainer
    
    eventSource.addEventListener("message", (event) => {
      const data = JSON.parse(event.data)
      
      if (data.done) {
        // ストリーミング完了
        eventSource.close()
        this.finishSSE()
      } else if (data.content) {
        // 文字を追加
        contentElement.textContent += data.content
        messagesContainer.scrollTop = messagesContainer.scrollHeight
      }
    })
    
    eventSource.onerror = (error) => {
      console.error("SSE Error:", error)
      eventSource.close()
      this.finishSSE()
    }
  }

  finishSSE() {
    // 送信ボタンを有効化
    this.submitTarget.disabled = false
    this.submitTarget.textContent = "送信"
    this.submitTarget.classList.remove("opacity-50", "cursor-not-allowed")
    
    // ローディング表示を削除
    const aiMessage = document.getElementById("ai-message-streaming")
    if (aiMessage) {
      const loadingDiv = aiMessage.querySelector(".flex.items-center")
      if (loadingDiv) {
        loadingDiv.remove()
      }
      
      // タイムスタンプを追加
      const contentContainer = aiMessage.querySelector(".inline-block")
      const now = new Date()
      const timeString = now.toLocaleTimeString('ja-JP', { hour: '2-digit', minute: '2-digit' })
      const timeSpan = document.createElement("span")
      timeSpan.className = "text-xs opacity-75"
      timeSpan.textContent = timeString
      contentContainer.appendChild(timeSpan)
      
      aiMessage.id = "" // IDを削除
    }
  }
}
