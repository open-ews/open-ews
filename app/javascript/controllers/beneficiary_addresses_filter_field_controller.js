import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggleElement", "fieldName"]

  connect() {
    this.toggle()
  }

  toggle() {
    const enabled = this.toggleElementTarget.checked

    this.fieldNameTarget.disabled = !enabled
  }
}
