import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggleElement", "fieldName", "operator"]

  connect() {
    this.toggle()
  }

  toggle() {
    const enabled = this.toggleElementTarget.checked

    this.fieldNameTarget.disabled = !enabled
    this.operatorTarget.disabled = !enabled
  }
}
