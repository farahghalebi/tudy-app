import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    document.addEventListener('click', (event) => {
      if (!this.element.contains(event.target)) {
        this.menuTarget.classList.remove("show")
      }
    })
  }

  toggle(event) {
    console.log("meow")
    event.preventDefault()
    this.menuTarget.classList.toggle("show")
  }
}
