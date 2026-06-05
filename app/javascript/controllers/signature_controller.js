import { Controller } from "@hotwired/stimulus"
import SignaturePad from "signature_pad"

// Wraps signature_pad to capture an SVG signature into a hidden input.
// HTML:
//   <div data-controller="signature">
//     <canvas data-signature-target="canvas" class="border rounded-md w-full h-48"></canvas>
//     <input type="hidden" name="delivery[signature_svg]" data-signature-target="input">
//     <button type="button" data-action="signature#clear">Limpar</button>
//   </div>
//
// On form submit (`signature#sync`), the SVG is serialized into the hidden input.
export default class extends Controller {
  static targets = ["canvas", "input"]

  connect() {
    this.resize()
    this.pad = new SignaturePad(this.canvasTarget, { backgroundColor: "rgb(255,255,255)" })
    window.addEventListener("resize", this.resize)
    this.element.closest("form")?.addEventListener("submit", this.sync)
  }

  disconnect() {
    window.removeEventListener("resize", this.resize)
    this.element.closest("form")?.removeEventListener("submit", this.sync)
  }

  clear() { this.pad.clear() }

  sync = (event) => {
    if (this.pad.isEmpty()) {
      event.preventDefault()
      alert(this.element.dataset.signatureMissingMessage || "Por favor, assine antes de confirmar.")
      return
    }
    this.inputTarget.value = this.pad.toDataURL("image/svg+xml")
  }

  resize = () => {
    // High-DPI scaling so the captured signature stays crisp.
    const canvas = this.canvasTarget
    const ratio = Math.max(window.devicePixelRatio || 1, 1)
    canvas.width = canvas.offsetWidth * ratio
    canvas.height = canvas.offsetHeight * ratio
    canvas.getContext("2d").scale(ratio, ratio)
    this.pad?.clear()
  }
}
