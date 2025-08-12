import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="broadcasts"
export default class extends Controller {
  static targets = ["channelInput", "audioFileInput", "messageInput"]

  connect() {
    this.toggleChannel()
  }

  toggleChannel() {
    switch (this.channelInputTarget.value) {
      case "voice":
        this.#toggleInput(this.audioFileInputTarget, true)
        this.#toggleInput(this.messageInputTarget, false)
        break
      case "sms":
        this.#toggleInput(this.messageInputTarget, true)
        this.#toggleInput(this.audioFileInputTarget, false)
        break
    }
  }

  #toggleInput(target, enable) {
    const input = target.querySelector("input, textarea, select")
    input.disabled = !enable
    target.style.display = enable ? "block" : "none"
  }
}
