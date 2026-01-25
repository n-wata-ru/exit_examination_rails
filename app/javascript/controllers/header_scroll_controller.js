import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.lastScrollY = window.scrollY
    this.threshold = 50
    
    window.addEventListener('scroll', this.handleScroll.bind(this))
  }

  disconnect() {
    window.removeEventListener('scroll', this.handleScroll.bind(this))
  }

  handleScroll() {
    const currentScrollY = window.scrollY
    
    // 下にスクロール（ヘッダーを隠す）
    if (currentScrollY > this.lastScrollY && currentScrollY > this.threshold) {
      this.element.classList.add('header-hidden')
    }
    // 上にスクロール（ヘッダーを表示）
    else if (currentScrollY < this.lastScrollY) {
      this.element.classList.remove('header-hidden')
    }
    
    this.lastScrollY = currentScrollY
  }
}
