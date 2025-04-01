import { Controller } from "@hotwired/stimulus";
import InspireTree from "inspire-tree";
import InspireTreeDOM from "inspire-tree-dom";

export default class extends Controller {
  static values = {
    fieldName: String,
    data: Array,
  };

  connect() {
    var tree = new InspireTree({
      selection: {
        mode: "checkbox",
      },
      data: this.dataValue,
    });

    new InspireTreeDOM(tree, {
      target: this.element,
    });

    tree
      .deepest()
      .available()
      .each((n) => {
        const node = n.itree.ref;
        const checkbox = node.querySelector('input[type="checkbox"]');

        checkbox.setAttribute("name", `${this.fieldNameValue}[]`);
        checkbox.setAttribute("value", node.getAttribute("data-uid"));
      });
  }
}
