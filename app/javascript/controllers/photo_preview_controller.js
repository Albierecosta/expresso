import { Controller } from "@hotwired/stimulus"

// Shows a thumbnail preview of the file picked in an <input type=file>.
// HTML:
//   <div data-controller="photo-preview">
//     <input type="file" accept="image/*" capture="environment"
//            data-photo-preview-target="input"
//            data-action="change->photo-preview#preview">
//     <img data-photo-preview-target="image" class="hidden">
//   </div>
export default class extends Controller {
  static targets = ["input", "image"]

  preview() {
    const file = this.inputTarget.files?.[0]
    if (!file) return
    const reader = new FileReader()
    reader.onload = (e) => {
      this.imageTarget.src = e.target.result
      this.imageTarget.classList.remove("hidden")
    }
    reader.readAsDataURL(file)
  }
}
