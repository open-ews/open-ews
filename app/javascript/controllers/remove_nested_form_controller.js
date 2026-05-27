import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["destroyElement"]

  remove(e) {
    e.preventDefault()

    this.element
      .querySelectorAll("input:not([type='hidden']), select, textarea")
      .forEach((el) => (el.disabled = true))

    this.element.classList.add("d-none")
    this.destroyElementTarget.value = "true"
  }
}
