import { Controller } from "@hotwired/stimulus"
import InspireTree from "inspire-tree"
import InspireTreeDOM from "inspire-tree-dom"

export default class extends Controller {
  static targets = ["toggleElement", "fieldName", "operator", "treeview"]

  static values = {
    fieldName: String,
    data: Array,
    selected: Array,
    readOnly: { type: Boolean, default: false },
  }

  connect() {
    this.#initializeTreeview()
    if (!this.readOnlyValue) {
      this.toggle()
    }
  }

  toggle() {
    const enabled = this.toggleElementTarget.checked

    this.fieldNameTarget.disabled = !enabled
    this.operatorTarget.disabled = !enabled

    if (!enabled) {
      this.#clearSelections()
    }
  }

  #initializeTreeview() {
    this.tree = new InspireTree({
      checkbox: {
        autoCheckChildren: true,
      },
      selection: {
        mode: "checkbox",
        disableDirectDeselection: true,
      },
      data: this.dataValue,
    })

    new InspireTreeDOM(this.tree, {
      target: this.treeviewTarget,
    })

    this.tree
      .deepest()
      .available()
      .each((n) => {
        const node = n.itree.ref
        const checkbox = node.querySelector('input[type="checkbox"]')
        const originalLabel = node.querySelector("a.title")
        const parent = originalLabel.parentNode

        const label = document.createElement("a")
        label.className = "title icon"
        label.innerHTML = originalLabel.innerHTML
        parent.replaceChild(label, originalLabel)

        checkbox.setAttribute("name", `${this.fieldNameValue}[value][]`)
        checkbox.setAttribute("value", node.getAttribute("data-uid"))

        if (this.selectedValue.includes(n.id)) {
          n.check()
        }
      })

    this.tree.available().each((n) => {
      const node = n.itree.ref
      const checkbox = node.querySelector('input[type="checkbox"]')

      if (checkbox.checked && !checkbox.indeterminate) {
        console.log(checkbox)
      }

      if (!checkbox.checked && !checkbox.indeterminate) {
        n.hide()
      } else if (this.readOnlyValue) {
        n.expand()
        checkbox.disabled = true
        checkbox.readonly = true
      }
    })
  }

  #clearSelections() {
    this.tree.deselectDeep()
  }
}
