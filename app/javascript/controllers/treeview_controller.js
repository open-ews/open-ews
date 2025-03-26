import { Controller } from "@hotwired/stimulus";
import InspireTree from "inspire-tree";
import InspireTreeDOM from "inspire-tree-dom";

export default class extends Controller {
  static values = {
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
      showCheckboxes: true,
      target: this.element,
    });
  }
}
