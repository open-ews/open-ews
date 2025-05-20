import { Controller } from "@hotwired/stimulus"

const MULTIPLE_VALUE_OPERATORS = ["in", "not_in"]
const BETWEEN_OPERATOR = "between"

export default class extends Controller {
  static targets = [
    "toggleElement",
    "fieldName",
    "operator",
    "value",
    "multiValue",
    "isNullValue",
    "betweenValue",
  ]

  connect() {
    this.#toggleInputs()
  }

  toggle() {
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
      this.operatorTarget.value
    )
    const isBetweenSelected = this.operatorTarget.value === BETWEEN_OPERATOR
    const isSingleSelected =
      enabled && !isNullSelected && !isMultiSelected && !isBetweenSelected

    this.fieldNameTarget.disabled = !enabled
    this.operatorTarget.disabled = !enabled

    this.isNullValueTarget.disabled = !isNullSelected
    this.isNullValueTarget.style.display = isNullSelected ? "unset" : "none"

    this.valueTarget.disabled = !isSingleSelected
    this.valueTarget.closest(".value-input").style.display =
      isSingleSelected || !enabled ? "unset" : "none"

    this.multiValueTarget.disabled = !isMultiSelected
    this.multiValueTarget.closest(".multi-value-input").style.display =
      isMultiSelected ? "unset" : "none"

    const tomSelect = this.multiValueTarget.tomselect
    if (tomSelect) {
      this.multiValueTarget.disabled ? tomSelect.disable() : tomSelect.enable()
    }

    if (this.hasBetweenValueTarget) {
      this.betweenValueTargets.forEach(
        (input) => (input.disabled = !isBetweenSelected)
      )
      this.betweenValueTarget.closest(".between-value-input").style.display =
        isBetweenSelected ? "unset" : "none"
    }
  }

  #clearInputValue() {
    this.isNullValueTarget.value = null
    this.valueTarget.value = null
    this.multiValueTarget.value = null

    if (this.hasBetweenValueTarget) {
      this.betweenValueTargets.forEach((input) => (input.value = null))
    }

    const tomSelect = this.multiValueTarget.tomselect
    tomSelect.clear()
    tomSelect.sync()
  }
}
