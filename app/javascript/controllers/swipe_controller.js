// app/javascript/controllers/swipe_controller.js
import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["input", "submit"] // Add this if you need the toggle functionality

  static values = {
    rightUrl: String,
    leftUrl: String,
    upUrl: String,
    downUrl: String,
    threshold: { type: Number, default: 50 },
    restraint: { type: Number, default: 80 },
    allowedTime: { type: Number, default: 350 },
    guard: { type: Number, default: 10 }
  }

  connect() {
    this._sx = 0; this._sy = 0; this._t0 = 0; this._locked = null
    this._onStart = this._onStart.bind(this)
    this._onMove = this._onMove.bind(this)
    this._onEnd = this._onEnd.bind(this)

    // Call toggle submit button if targets exist
    if (this.hasInputTarget && this.hasSubmitTarget) {
      this.toggleSubmitButton()
    }

    document.addEventListener("touchstart", this._onStart, { passive: true })
    document.addEventListener("touchmove", this._onMove, { passive: false })
    document.addEventListener("touchend", this._onEnd, { passive: true })
  }

  disconnect() {
    document.removeEventListener("touchstart", this._onStart)
    document.removeEventListener("touchmove", this._onMove)
    document.removeEventListener("touchend", this._onEnd)
  }

  // Submit form with swiper
  toggleSubmitButton() {
    const isInputEmpty = this.inputTarget.value.trim() === "";
    this.submitTarget.disabled = isInputEmpty;
  }

  _onStart(e) {
    const t = e.changedTouches[0]
    this._sx = t.pageX; this._sy = t.pageY; this._t0 = Date.now()
    this._locked = null
  }

  _onMove(e) {
    const t = e.changedTouches[0]
    const dx = t.pageX - this._sx
    const dy = t.pageY - this._sy

    if (this._locked === null && (Math.abs(dx) > this.guardValue || Math.abs(dy) > this.guardValue)) {
      this._locked = Math.abs(dx) > Math.abs(dy) ? "x" : "y"
    }

    if (this._locked === "x") e.preventDefault()
  }

  _onEnd(e) {
    const t = e.changedTouches[0]
    const dx = t.pageX - this._sx
    const dy = t.pageY - this._sy
    const dt = Date.now() - this._t0

    if (dt > this.allowedTimeValue) return

    const horizontal = Math.abs(dx) >= this.thresholdValue && Math.abs(dy) <= this.restraintValue
    const vertical = Math.abs(dy) >= this.thresholdValue && Math.abs(dx) <= this.restraintValue

    if (horizontal) {
      if (dx > 0) this._go("right")
      if (dx < 0) this._go("left")
    } else if (vertical) {
      if (dy < 0) this._go("up")
      if (dy > 0) this._go("down")
    }
  }

  _go(dir) {
    const formEl = this.element.querySelector("form")
    const vt = (fn) => (document.startViewTransition ? document.startViewTransition(fn) : fn())

    if (dir === "right") {
      // Prefer visiting configured URL; otherwise submit form
      if (this.hasRightUrlValue) return vt(() => Turbo.visit(this.rightUrlValue))
      if (formEl) return vt(() => formEl.requestSubmit())
    } else if (dir === "left") {
      if (this.hasLeftUrlValue) return vt(() => Turbo.visit(this.leftUrlValue))
    } else if (dir === "up") {
      if (this.hasUpUrlValue) return vt(() => Turbo.visit(this.upUrlValue))
    } else if (dir === "down") {
      if (this.hasDownUrlValue) return vt(() => Turbo.visit(this.downUrlValue))
    }
  }
}
