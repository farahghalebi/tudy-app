import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]
  static classes = ["truncated"]

  connect() {
    setTimeout(() => {
      this.checkTruncation()
    }, 0);
  }

  checkTruncation() {
    const isTruncated = this.contentTarget.scrollHeight > this.contentTarget.clientHeight;
    if (isTruncated) {
      this.contentTarget.classList.add(this.truncatedClass);
    }
  }

  toggle() {
    this.contentTarget.classList.toggle(this.truncatedClass)
  }
}
