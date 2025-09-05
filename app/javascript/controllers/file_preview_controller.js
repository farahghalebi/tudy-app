import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "filename"]

  connect() {
    // initialize
    this.updateFilename()
    console.log("🐰 file_preview_controller connected 🐰")
  }

  updateFilename() {
    const fileName = this.inputTarget.files.length
      ? "✓"
      : ""
    this.filenameTarget.textContent = fileName
  }
}
