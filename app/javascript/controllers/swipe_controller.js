// controllers/swipe_controller.js
import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static values = {
    rightUrl: String,
    leftUrl: String,
    upUrl: String,
    downUrl: String,
    threshold:   { type: Number, default: 30 },
    restraint:   { type: Number, default: 80 },
    allowedTime: { type: Number, default: 350 },
    guard:       { type: Number, default: 10 }
  }

  connect() {
    this._sx = 0; this._sy = 0; this._t0 = 0; this._locked = null
    this._onStart = this._onStart.bind(this)
    this._onMove  = this._onMove.bind(this)
    this._onEnd   = this._onEnd.bind(this)

    document.addEventListener("touchstart", this._onStart, { passive: true })
    document.addEventListener("touchmove",  this._onMove,  { passive: false })
    document.addEventListener("touchend",   this._onEnd,   { passive: true })
  }

  disconnect() {
    document.removeEventListener("touchstart", this._onStart)
    document.removeEventListener("touchmove",  this._onMove)
    document.removeEventListener("touchend",   this._onEnd)
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
    if (this._locked === "x") e.preventDefault() // lock horizontal scroll for confident swipe
  }

  _onEnd(e) {
    const t = e.changedTouches[0]
    const dx = t.pageX - this._sx
    const dy = t.pageY - this._sy
    const dt = Date.now() - this._t0
    if (dt > this.allowedTimeValue) return

    const horizontal = Math.abs(dx) >= this.thresholdValue && Math.abs(dy) <= this.restraintValue
    const vertical   = Math.abs(dy) >= this.thresholdValue && Math.abs(dx) <= this.restraintValue

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

    const submitIfValid = () => {
      if (!formEl) return
      const textarea = formEl.querySelector("textarea")
      const value = textarea ? textarea.value.trim() : ""
      if (value.length === 0) {
        textarea?.reportValidity()
        return
      }
      formEl.requestSubmit()
    }

    if (dir === "left") {
      // If a left URL is provided, go there; otherwise submit form
      if (this.hasLeftUrlValue) return vt(() => Turbo.visit(this.leftUrlValue))
      return vt(submitIfValid)
    }

    if (dir === "right" && this.hasRightUrlValue) return vt(() => Turbo.visit(this.rightUrlValue))
    if (dir === "up"    && this.hasUpUrlValue)    return vt(() => Turbo.visit(this.upUrlValue))
    if (dir === "down"  && this.hasDownUrlValue)  return vt(() => Turbo.visit(this.downUrlValue))
  }
}
