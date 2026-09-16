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
    const enabled = this.toggleElementTarget.checked
    const operator = this.operatorTarget.value

    // 1. Control fields
    this.fieldNameTarget.disabled = !enabled
    this.operatorTarget.disabled = !enabled

    // 2. Determine active input mode
    let activeMode = "single"
    if (operator === "is_null") activeMode = "null"
    else if (["in", "not_in"].includes(operator)) activeMode = "multi"
    else if (operator === "between") activeMode = "between"

    // 3. Set Input Disabled States
    this.#toggleInputState(
      this.hasValueTarget ? this.valueTarget : null,
      enabled && activeMode === "single",
    )
    this.#toggleInputState(
      this.hasIsNullValueTarget ? this.isNullValueTarget : null,
      enabled && activeMode === "null",
    )
    this.#toggleInputState(
      this.hasMultiValueTarget ? this.multiValueTarget : null,
      enabled && activeMode === "multi",
      true,
    )
    this.#toggleInputState(
      this.hasBetweenValueTarget ? this.betweenValueTargets : null,
      enabled && activeMode === "between",
    )

    // 4. Set Wrapper Visibility States
    const showSingleWrapper = enabled ? activeMode === "single" : true
    const showNullWrapper = enabled && activeMode === "null"
    const showMultiWrapper = enabled && activeMode === "multi"
    const showBetweenWrapper = enabled && activeMode === "between"

    if (this.hasValueWrapperTarget)
      this.valueWrapperTarget.hidden = !showSingleWrapper
    if (this.hasIsNullValueWrapperTarget)
      this.isNullValueWrapperTarget.hidden = !showNullWrapper
    if (this.hasMultiValueWrapperTarget)
      this.multiValueWrapperTarget.hidden = !showMultiWrapper
    if (this.hasBetweenValueWrapperTarget)
      this.betweenValueWrapperTarget.hidden = !showBetweenWrapper
  }

  // Called when the row checkbox changes
  toggle() {
    if (!this.toggleElementTarget.checked) {
      this.#clearOperator()
      this.#clearValuesOnly()
    }
    this.sync()
  }

  // Called when the operator dropdown changes
  operatorChanged() {
    this.#clearValuesOnly()
    this.sync()
  }

  #toggleInputState(inputOrInputs, isActive, isMulti = false) {
    if (!inputOrInputs) return

    const inputs = Array.isArray(inputOrInputs)
      ? inputOrInputs
      : [inputOrInputs]
    inputs.forEach((input) => (input.disabled = !isActive))

    if (isMulti && inputOrInputs?.tomselect) {
      isActive
        ? inputOrInputs.tomselect.enable()
        : inputOrInputs.tomselect.disable()
    }
  }

  #clearOperator() {
    if (this.hasOperatorTarget) {
      this.operatorTarget.value = ""
    }
  }

  #clearValuesOnly() {
    const inputsToClear = [
      ...(this.hasValueTarget ? [this.valueTarget] : []),
      ...(this.hasIsNullValueTarget ? [this.isNullValueTarget] : []),
      ...(this.hasMultiValueTarget ? [this.multiValueTarget] : []),
      ...(this.hasBetweenValueTarget ? this.betweenValueTargets : []),
    ]

    inputsToClear.forEach((input) => {
      if (input) input.value = ""
    })

    if (this.hasMultiValueTarget && this.multiValueTarget?.tomselect) {
      this.multiValueTarget.tomselect.clear()
      this.multiValueTarget.tomselect.sync()
    }
  }
}
