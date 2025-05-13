import { Controller } from "@hotwired/stimulus"

const MULTIPLE_VALUE_OPERATORS = ["in", "not_in"]

export default class extends Controller {
  static targets = [
    "toggleElement",
    "fieldName",
    "operator",
    "value",
    "multiValue",
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

    this.#clearInputValue()
    this.#toggleInputs()
  }

  operatorChanged() {
    this.#clearInputValue()
    this.#toggleInputs()
  }

  #toggleInputs() {
    const enabled = this.toggleElementTarget.checked

    const isNullSelected = this.operatorTarget.value === "is_null"
    const isMultiSelected = MULTIPLE_VALUE_OPERATORS.includes(
      this.operatorTarget.value,
    )

    this.fieldNameTarget.disabled = !enabled
    this.operatorTarget.disabled = !enabled

    this.isNullValueTarget.disabled = !isNullSelected
    this.isNullValueTarget.style.display = isNullSelected ? "unset" : "none"

    if (enabled) {
      if (isMultiSelected) {
        this.valueTarget.disabled = true
        this.valueTarget.closest(".value-input").style.display = "none"

        this.multiValueTarget.disabled = false
        this.multiValueTarget.closest(".multi-value-input").style.display =
          "unset"
      } else {
        this.valueTarget.disabled = false
        this.valueTarget.closest(".value-input").style.display = "unset"

        this.multiValueTarget.disabled = true
        this.multiValueTarget.closest(".multi-value-input").style.display =
          "none"
      }
    } else {
      this.valueTarget.disabled = true
      this.valueTarget.closest(".value-input").style.display = "none"

      this.multiValueTarget.disabled = true
      this.multiValueTarget.closest(".multi-value-input").style.display = "none"
    }

    const tomSelect = this.multiValueTarget.tomselect
    if (tomSelect) {
      this.multiValueTarget.disabled ? tomSelect.disable() : tomSelect.enable()
    }
  }

  #clearInputValue() {
    this.isNullValueTarget.value = null
    this.valueTarget.value = null
    this.multiValueTarget.value = null

    const tomSelect = this.multiValueTarget.tomselect
    if (tomSelect) {
      tomSelect.clear()
      tomSelect.sync()
    }
  }
}
