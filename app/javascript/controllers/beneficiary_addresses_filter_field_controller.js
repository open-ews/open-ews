import { Controller } from "@hotwired/stimulus"
import InspireTree from "inspire-tree"
import InspireTreeDOM from "inspire-tree-dom"

export default class extends Controller {
  static targets = ["toggleElement", "fieldName", "operator", "treeview"]

  static values = {
    fieldName: String,
    data: Array,
    selected: Array,
  }

  connect() {
    this.#initializeTreeview()
    this.toggle()
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
        checkbox.setAttribute("name", `${this.fieldNameValue}[value][]`)
        checkbox.setAttribute("value", node.getAttribute("data-uid"))

        if (this.selectedValue.includes(n.id)) {
          n.check()
        }
      })
  }

  #clearSelections() {
    this.tree.deselectDeep()
  }
}
