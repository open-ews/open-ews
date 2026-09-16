import { Controller } from "@hotwired/stimulus"
import InspireTree from "inspire-tree"
import InspireTreeDOM from "inspire-tree-dom"

// Connects to data-controller="geocode-tree"
export default class extends Controller {
  static values = {
    data: Array,
    selected: Array,
  }
  static targets = ["targetAreasInput", "treeContainer"]

  connect() {
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
      target: this.treeContainerTarget,
    })

    this.tree.on("node.state.changed", (node, property, oldValue, newValue) => {
      if (property === "checked") {
        this.#updateGeocodeTargetAreas()
      }
    })

    this.#markChecked()
    this.#updateGeocodeTargetAreas()
  }

  #markChecked() {
    if (!this.hasSelectedValue || this.selectedValue.length === 0) return

    const selectedPaths = new Set(
      this.selectedValue.map((path) => this.#pathKey(path)),
    )

    this.tree.available().each((n) => {
      if (selectedPaths.has(this.#pathKey(n.metadata.path))) {
        n.check()
      }
    })
  }

  #updateGeocodeTargetAreas() {
    if (!this.hasTargetAreasInputTarget) return

    const areaMap = new Map()

    const collectAreas = (nodes) => {
      nodes.each((node) => {
        if (node.checked()) {
          const key = this.#pathKey(node.metadata.path)
          areaMap.set(key, node.metadata.area_definition)
        } else if (node.hasChildren()) {
          collectAreas(node.getChildren())
        }
      })
    }

    collectAreas(this.tree.nodes())

    this.targetAreasInputTarget.value = JSON.stringify(
      Array.from(areaMap.values()),
    )
  }

  #pathKey(path) {
    return path.join(".")
  }
}
