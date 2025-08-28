import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails"


// Adds left/right swipe navigation with sensible defaults.
// Use data-swipe-right-url-value / data-swipe-left-url-value on the element.
export default class extends Controller {
  static values = {
    rightUrl: String,
    leftUrl: String,
    threshold:  { type: Number, default: 50 }, // px
    restraint:  { type: Number, default: 80 },  // px
    allowedTime:{ type: Number, default: 350 }, // ms
    guard:      { type: Number, default: 10 }   // px before locking direction
  }

  connect() {
    this._sx = 0; this._sy = 0; this._t0 = 0; this._locked = null;

    this._onStart = this._onStart.bind(this);
    this._onMove  = this._onMove.bind(this);
    this._onEnd   = this._onEnd.bind(this);


    document.addEventListener("touchstart", this._onStart, { passive: true });
    document.addEventListener("touchmove",  this._onMove,  { passive: false });
    document.addEventListener("touchend",   this._onEnd,   { passive: true });

    // Optional: desktop arrow keys to simulate swipe
    this._onKey = (e) => {
      if (e.key === "ArrowLeft"  && this.hasLeftUrlValue)  Turbo.visit(this.leftUrlValue);
      if (e.key === "ArrowRight" && this.hasRightUrlValue) Turbo.visit(this.rightUrlValue);
    };
    document.addEventListener("keydown", this._onKey);
  }

  disconnect() {
    document.removeEventListener("touchstart", this._onStart);
    document.removeEventListener("touchmove",  this._onMove);
    document.removeEventListener("touchend",   this._onEnd);
    document.removeEventListener("keydown", this._onKey);
  }

  _onStart(e) {
    const t = e.changedTouches[0];
    this._sx = t.pageX;
    this._sy = t.pageY;
    this._t0 = Date.now();
    this._locked = null;
    console.log("start")
  }

  _onMove(e) {
    const t = e.changedTouches[0];
    const dx = t.pageX - this._sx;
    const dy = t.pageY - this._sy;

    if (this._locked === null && (Math.abs(dx) > this.guardValue || Math.abs(dy) > this.guardValue)) {
      this._locked = Math.abs(dx) > Math.abs(dy) ? "x" : "y";
    }

    // Only prevent default when horizontal, so vertical scroll stays smooth
    if (this._locked === "x") e.preventDefault();
  }

  _onEnd(e) {
    const t = e.changedTouches[0];
    const dx = t.pageX - this._sx;
    const dy = t.pageY - this._sy;
    const dt = Date.now() - this._t0;

    if (dt > this.allowedTimeValue) return;

    const horizontal = Math.abs(dx) >= this.thresholdValue && Math.abs(dy) <= this.restraintValue;
    if (!horizontal) return;

    if (dx > 0 && this.hasRightUrlValue) Turbo.visit(this.rightUrlValue); // right swipe
    if (dx < 0 && this.hasLeftUrlValue)  Turbo.visit(this.leftUrlValue);  // left  swipe
  }
}
