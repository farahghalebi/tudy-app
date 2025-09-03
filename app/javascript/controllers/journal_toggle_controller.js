import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["box"];

  toggle() {
    this.boxTarget.classList.toggle("hidden");
  }
}
