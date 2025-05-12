import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

const MULTIPLE_VALUE_OPERATORS = ["in", "not_in"]

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

    if (this.valueTarget.tagName === "SELECT") {
      this.#toggleSelectInput()
    }
  }

  #toggleSelectInput() {
    this.valueTarget.name = this.valueTarget.name.replace("[]", "")

    if (MULTIPLE_VALUE_OPERATORS.includes(this.operatorTarget.value)) {
      this.valueTarget.multiple = true
      this.valueTarget.name = `${this.valueTarget.name}[]`
    } else {
      this.valueTarget.multiple = undefined
    }

    let tomSelect = this.valueTarget.tomselect
    if (tomSelect) {
      tomSelect.destroy()
    }

    this.valueTarget.querySelectorAll("option").forEach((e) => {
      e.removeAttribute("selected")
    })

    if (this.valueTarget.multiple === true) {
      tomSelect = new TomSelect(this.valueTarget)
      this.valueTarget.disabled ? tomSelect.disable() : tomSelect.enable()
    }
  }
}
