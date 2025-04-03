import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["element", "destroyElement"];

  remove(e) {
    e.preventDefault();

    this.elementTarget.style.display = "none";
    this.destroyElementTarget.value = "true";
  }
}
