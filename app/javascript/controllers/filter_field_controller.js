import { Controller } from "@hotwired/stimulus"

const STATIC_MODE_MAP = {
  is_null: "null",
  in: "multi",
  not_in: "multi",
  between: "between",
}

export default class extends Controller {
  static values = {
    schemaType: String, // "array", "list", "value", "string", etc.
  }

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
    const isHidden = !!this.element.closest("[hidden]")
    const enabled = this.toggleElementTarget.checked && !isHidden
    const activeMode = this.#resolveActiveMode()

    this.fieldNameTarget.disabled = !enabled
    this.operatorTarget.disabled = !enabled

    // Keep the active mode wrapper visible even when disabled so an input is always shown
    const groups = [
      {
        key: "single",
        input: "value",
        wrapper: "valueWrapper",
        visible: activeMode === "single",
      },
      {
        key: "null",
        input: "isNullValue",
        wrapper: "isNullValueWrapper",
        visible: activeMode === "null",
      },
      {
        key: "multi",
        input: "multiValue",
        wrapper: "multiValueWrapper",
        visible: activeMode === "multi",
        isMulti: true,
      },
      {
        key: "between",
        input: "betweenValue",
        wrapper: "betweenValueWrapper",
        visible: activeMode === "between",
        isArray: true,
      },
    ]

    groups.forEach((g) => this.#syncGroup(g, enabled, activeMode))
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

  #resolveActiveMode() {
    const operator = this.operatorTarget.value

    if (STATIC_MODE_MAP[operator]) {
      return STATIC_MODE_MAP[operator]
    }

    // Array attributes always route to multi mode
    if (this.schemaTypeValue === "array") {
      return "multi"
    }

    return "single"
  }

  #syncGroup(
    { key, input, wrapper, visible, isMulti, isArray },
    enabled,
    activeMode,
  ) {
    const isActive = enabled && activeMode === key
    const isWrapperVisible = visible ?? isActive

    const inputTarget = isArray
      ? this.hasBetweenValueTarget
        ? this.betweenValueTargets
        : null
      : this.#target(input)

    const wrapperTarget = this.#target(wrapper)

    if (inputTarget) {
      const inputs = Array.isArray(inputTarget) ? inputTarget : [inputTarget]
      inputs.forEach((i) => (i.disabled = !isActive))
    }

    if (wrapperTarget) {
      wrapperTarget.hidden = !isWrapperVisible
    }

    if (isMulti && inputTarget?.tomselect) {
      isActive
        ? inputTarget.tomselect.enable()
        : inputTarget.tomselect.disable()
    }
  }

  #target(name) {
    const capitalized = name.charAt(0).toUpperCase() + name.slice(1)
    return this[`has${capitalized}Target`] ? this[`${name}Target`] : null
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
      this.multiValueTarget.tomselect.clear(true)
      this.multiValueTarget.tomselect.clearOptions()
      this.multiValueTarget.tomselect.sync()
    }
  }
}
