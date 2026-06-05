import { Controller } from "@hotwired/stimulus"

// Uses the Web Share API when available (mostly mobile); falls back to
// copying the URL to clipboard with a brief alert.
export default class extends Controller {
  static values = { url: String, title: String }

  async trigger(event) {
    event.preventDefault()
    if (navigator.share) {
      try {
        await navigator.share({ url: this.urlValue, title: this.titleValue })
      } catch (_) { /* user cancelled */ }
    } else if (navigator.clipboard) {
      await navigator.clipboard.writeText(this.urlValue)
      alert("Link copiado!")
    } else {
      window.prompt("Copie o link:", this.urlValue)
    }
  }
}
