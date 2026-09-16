import { Controller } from "@hotwired/stimulus"

const MODE_MAP = {
  is_null: "null",
  in: "multi",
  not_in: "multi",
  between: "between",
}

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
    const isHidden = !!this.element.closest("[hidden]")
    const enabled = this.toggleElementTarget.checked && !isHidden
    const activeMode = MODE_MAP[this.operatorTarget.value] || "single"

    this.fieldNameTarget.disabled = !enabled
    this.operatorTarget.disabled = !enabled

    const groups = [
      {
        key: "single",
        input: "value",
        wrapper: "valueWrapper",
        visible: !enabled || activeMode === "single",
      },
      { key: "null", input: "isNullValue", wrapper: "isNullValueWrapper" },
      {
        key: "multi",
        input: "multiValue",
        wrapper: "multiValueWrapper",
        isMulti: true,
      },
      {
        key: "between",
        input: "betweenValue",
        wrapper: "betweenValueWrapper",
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
      this.multiValueTarget.tomselect.clear()
      this.multiValueTarget.tomselect.sync()
    }
  }
}
