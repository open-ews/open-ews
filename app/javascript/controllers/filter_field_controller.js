import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "toggleElement",
    "fieldName",
    "operator",
    "value",
    "valueWrapper",
    "multiValue",
    "multiValueWrapper",
    "isNullValue",
    "isNullValueWrapper",
    "betweenValue",
    "betweenValueWrapper",
  ]

  connect() {
    this.sync()
  }

  sync() {
    // A row is only active if checked AND visible in the DOM
    const isContainerHidden = this.element.closest("[hidden]") !== null
    const enabled = this.toggleElementTarget.checked && !isContainerHidden
    const op = this.operatorTarget.value

    this.fieldNameTarget.disabled = !enabled
    this.operatorTarget.disabled = !enabled

    // Map operator directly to active key
    const modeMap = {
      is_null: "null",
      in: "multi",
      not_in: "multi",
      between: "between",
    }
    const activeMode = modeMap[op] || "single"

    // 1. Single Value
    this.#syncGroup(
      this.hasValueTarget ? this.valueTarget : null,
      this.hasValueWrapperTarget ? this.valueWrapperTarget : null,
      enabled && activeMode === "single",
      !enabled || activeMode === "single",
    )

    // 2. Is Null
    this.#syncGroup(
      this.hasIsNullValueTarget ? this.isNullValueTarget : null,
      this.hasIsNullValueWrapperTarget ? this.isNullValueWrapperTarget : null,
      enabled && activeMode === "null",
    )

    // 3. Multi Select
    this.#syncGroup(
      this.hasMultiValueTarget ? this.multiValueTarget : null,
      this.hasMultiValueWrapperTarget ? this.multiValueWrapperTarget : null,
      enabled && activeMode === "multi",
      enabled && activeMode === "multi",
      true,
    )

    // 4. Between Values
    this.#syncGroup(
      this.hasBetweenValueTarget ? this.betweenValueTargets : null,
      this.hasBetweenValueWrapperTarget ? this.betweenValueWrapperTarget : null,
      enabled && activeMode === "between",
    )
  }

  toggle() {
    if (!this.toggleElementTarget.checked) {
      this.operatorTarget.value = ""
      this.#clearValues()
    }
    this.sync()
  }

  operatorChanged() {
    this.#clearValues()
    this.sync()
  }

  #syncGroup(
    inputOrInputs,
    wrapper,
    isActive,
    isVisible = isActive,
    isMulti = false,
  ) {
    if (inputOrInputs) {
      const inputs = Array.isArray(inputOrInputs)
        ? inputOrInputs
        : [inputOrInputs]
      inputs.forEach((input) => (input.disabled = !isActive))
    }

    if (wrapper) {
      wrapper.hidden = !isVisible
    }

    if (isMulti && inputOrInputs?.tomselect) {
      isActive
        ? inputOrInputs.tomselect.enable()
        : inputOrInputs.tomselect.disable()
    }
  }

  #clearValues() {
    this.element
      .querySelectorAll("input:not([type='checkbox']), select, textarea")
      .forEach((input) => {
        if (input !== this.fieldNameTarget && input !== this.operatorTarget) {
          input.value = ""
        }
      })

    if (this.hasMultiValueTarget && this.multiValueTarget?.tomselect) {
      this.multiValueTarget.tomselect.clear()
      this.multiValueTarget.tomselect.sync()
    }
  }
}
