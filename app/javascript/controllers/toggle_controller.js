// app/javascript/controllers/todo_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  toggleForm() {
    this.formTarget.style.display = this.formTarget.style.display === "none" ? "block" : "none";
  }
}
