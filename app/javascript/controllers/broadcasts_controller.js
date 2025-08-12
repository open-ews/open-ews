import { Controller } from "@hotwired/stimulus"
const { SegmentedMessage } = require("sms-segments-calculator")

// Connects to data-controller="broadcasts"
export default class extends Controller {
  static targets = ["channelInput", "audioFileInput", "messageInput"]
  static values = {
    messageSegmentWarningThreshold: Number,
  }

  connect() {
    this.toggleChannel()
    this.checkSegments()
  }

  checkSegments() {
    const input = this.#getInputTarget(this.messageInputTarget)
    const segmentedMessage = new SegmentedMessage(input.value)
    const warningTarget = this.#getWarningTarget(this.messageInputTarget)

    if (
      segmentedMessage.segmentsCount > this.messageSegmentWarningThresholdValue
    ) {
      warningTarget.style.display = "block"
    } else {
      warningTarget.style.display = "none"
    }
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
    const input = this.#getInputTarget(target)
    input.disabled = !enable
    target.style.display = enable ? "block" : "none"
  }

  #getInputTarget(target) {
    return target.querySelector("input, textarea, select")
  }

  #getWarningTarget(target) {
    return target.querySelector(".input-warning")
  }
}
