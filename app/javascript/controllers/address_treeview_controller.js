import { Controller } from "@hotwired/stimulus"
import InspireTree from "inspire-tree"
import InspireTreeDOM from "inspire-tree-dom"

export default class extends Controller {
  static values = {
    fieldName: String,
    data: Array,
    selected: Array,
  }

  connect() {
    this.tree = new InspireTree({
      checkbox: {
        autoCheckChildren: true,
      },
      selection: {
        mode: "checkbox",
      },
      data: this.dataValue,
    })

    new InspireTreeDOM(this.tree, {
      target: this.element,
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

  clearSelection() {
    this.tree.deselectDeep()
  }
}
