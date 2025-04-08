import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggleElement", "fieldName", "operator", "value"]

  connect() {
    this.toggle()
  }

  toggle() {
    const enabled = this.toggleElementTarget.checked

    this.fieldNameTarget.disabled = !enabled
    this.operatorTarget.disabled = !enabled
    this.operatorTarget.value = null

    // NOTE: handle multiple value inputs (eg. date select)
    this.valueTargets.forEach((e) => {
      e.disabled = !enabled
      e.value = null
    })
  }
}
