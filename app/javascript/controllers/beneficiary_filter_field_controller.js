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
    const isNullSelected = this.operatorTarget.value === "is_null"

    this.fieldNameTarget.disabled = !enabled
    this.operatorTarget.disabled = !enabled

    this.isNullValueTarget.disabled = !isNullSelected
    this.isNullValueTarget.style.display = isNullSelected ? "unset" : "none"

    this.valueTarget.disabled = !enabled || isNullSelected
    this.valueTarget.closest(".value-input").style.display = isNullSelected
      ? "none"
      : "unset"

    const tomSelect = this.valueTarget.tomselect
    if (tomSelect) {
      this.valueTarget.disabled ? tomSelect.disable() : tomSelect.enable()
    }
  }

  #toggleValueInput() {
    const enabled = this.toggleElementTarget.checked
    const isNullSelected = this.operatorTarget.value === "is_null"

    this.isNullValueTarget.value = null
    this.isNullValueTarget.disabled = !isNullSelected
    this.isNullValueTarget.style.display = isNullSelected ? "unset" : "none"

    this.valueTarget.value = null
    this.valueTarget.disabled = !enabled || isNullSelected
    this.valueTarget.closest(".value-input").style.display = isNullSelected
      ? "none"
      : "unset"

    const tomSelect = this.valueTarget.tomselect
    if (tomSelect) {
      this.valueTarget.disabled ? tomSelect.disable() : tomSelect.enable()

      // FIXME: switching between single and multiple items
      this.valueTarget.multiple = "true"
      tomSelect.setMaxItems(null)

      tomSelect.sync()
    }
  }
}
