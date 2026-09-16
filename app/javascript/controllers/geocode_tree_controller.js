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
  }

  #markChecked() {
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
    const areas = new Set()

    const collectAreas = (nodes) => {
      nodes.each((node) => {
        if (node.checked()) {
          // Store stringified JSON of node.metadata.geocode_area in Set for uniqueness
          areas.add(JSON.stringify(node.metadata.area_definition))
        } else if (node.hasChildren()) {
          collectAreas(node.getChildren())
        }
      })
    }

    collectAreas(this.tree.nodes())

    const areaObjects = Array.from(areas).map((item) => JSON.parse(item))

    // Update the input target value
    if (this.hasTargetAreasInputTarget) {
      this.targetAreasInputTarget.value = JSON.stringify(areaObjects)
    }
  }

  #pathKey(path) {
    return path.join(".")
  }
}
