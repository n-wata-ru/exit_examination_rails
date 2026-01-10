import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "menu" ]

  // コントローラーが初期化される時
  connect() {
    this.boundHideOnClickOutside = this.hideOnClickOutside.bind(this)
  }

  // コントローラーが削除される時にリスナーをクリーンアップ
  disconnect() {
    document.removeEventListener('click', this.boundHideOnClickOutside)
  }

  // トグルボタンがクリックされた時
  toggle(event) {
    event.stopPropagation() // イベントの伝播を止める
    const isHidden = this.menuTarget.classList.contains("hidden")
    
    if (isHidden) {
      this.show()
    } else {
      this.hide()
    }
  }

  show() {
    this.menuTarget.classList.remove("hidden")
    // メニューを開いた後、次のクリックで外部クリックを検知
    setTimeout(() => {
      document.addEventListener('click', this.boundHideOnClickOutside)
    }, 0)
  }

  hide() {
    this.menuTarget.classList.add("hidden")
    document.removeEventListener('click', this.boundHideOnClickOutside)
  }

  hideOnClickOutside(event) {
    // クリックがメニュー内でない場合は閉じる
    if (!this.element.contains(event.target)) {
      this.hide()
    }
  }
}
