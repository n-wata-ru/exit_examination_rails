import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "status", "name", "origin", "variety", "process", "roastLevel", "notes"]
  static values = { url: String }

  analyze() {
    const file = this.inputTarget.files[0]
    if (!file) return

    this.setStatus("画像を解析しています...")

    const formData = new FormData()
    formData.append("image", file)

    fetch(this.urlValue, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "application/json"
      },
      body: formData
    })
      .then((response) => response.json().then((data) => ({ ok: response.ok, data })))
      .then(({ ok, data }) => {
        if (!ok) {
          this.setStatus(data.error || "画像の解析に失敗しました")
          return
        }
        this.applyResult(data)
      })
      .catch(() => {
        this.setStatus("画像の解析に失敗しました")
      })
  }

  applyResult(data) {
    if (data.name) this.nameTarget.value = data.name
    if (data.variety) this.varietyTarget.value = data.variety
    if (data.process) this.processTarget.value = data.process
    if (data.roast_level) this.roastLevelTarget.value = data.roast_level
    if (data.notes) this.notesTarget.value = data.notes

    if (data.origin_id) {
      this.originTarget.value = data.origin_id
    }

    if (data.origin_country && !data.origin_id) {
      this.setStatus(`産地候補: ${data.origin_country}（一致する選択肢がないため産地は手動で選択してください）`)
    } else {
      this.setStatus("画像から情報を反映しました。内容を確認してください。")
    }
  }

  setStatus(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
    }
  }
}
