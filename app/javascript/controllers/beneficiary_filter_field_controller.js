import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "toggleElement",
    "fieldName",
    "operator",
    "value",
    "isNullValue",
  ]

  connect() {
    this.#toggleInputs()
  }

  toggle() {
    const enabled = this.toggleElementTarget.checked

    this.fieldNameTarget.disabled = !enabled

    this.operatorTarget.disabled = !enabled
    this.operatorTarget.value = null

    this.#toggleValueInput()
  }

  operatorChanged() {
    this.#toggleValueInput()
  }

  #toggleInputs() {
    const enabled = this.toggleElementTarget.checked

    this.fieldNameTarget.disabled = !enabled
    this.operatorTarget.disabled = !enabled

    const isNullSelected = this.operatorTarget.value === "is_null"
    this.isNullValueTarget.disabled = !isNullSelected
    this.isNullValueTarget.style.display = isNullSelected ? "unset" : "none"

    // NOTE: handle multiple value inputs (eg. date select)
    this.valueTargets.forEach((e) => {
      e.disabled = !enabled || isNullSelected
      // NOTE: hide the entire wrapper
      e.closest(".value-input").style.display = isNullSelected
        ? "none"
        : "unset"
    })
  }

  #toggleValueInput() {
    const isNullSelected = this.operatorTarget.value === "is_null"

    this.isNullValueTarget.disabled = !isNullSelected
    this.isNullValueTarget.value = null
    this.isNullValueTarget.style.display = isNullSelected ? "unset" : "none"

    // NOTE: handle multiple value inputs (eg. date select)
    this.valueTargets.forEach((e) => {
      e.disabled = !this.toggleElementTarget.checked || isNullSelected
      // NOTE: hide the entire wrapper
      e.closest(".value-input").style.display = isNullSelected
        ? "none"
        : "unset"
      e.value = null
    })
  }
}
