import { Controller } from "@hotwired/stimulus"
import { SegmentedMessage } from "sms-segments-calculator"

// Connects to data-controller="broadcasts"
export default class extends Controller {
  static targets = ["channelInput", "audioFileInput", "messageInput"]
  static values = {
    messageSegmentWarningThreshold: Number,
    characterCountTranslations: Object,
  }

  connect() {
    this.toggleChannel()
    this.updateMessageInfo()
  }

  updateMessageInfo() {
    this.#updateCharacterCount()
    this.#checkSegments()
  }

  toggleChannel() {
    switch (this.channelInputTarget.value) {
      case "voice_call":
      case "audio":
        this.#toggleInput(this.audioFileInputTarget, true)
        this.#toggleInput(this.messageInputTarget, false)
        break
      case "text_message":
        this.#toggleInput(this.messageInputTarget, true)
        this.#toggleInput(this.audioFileInputTarget, false)
        break
    }
  }

  #updateCharacterCount() {
    const input = this.#getInputTarget(this.messageInputTarget)
    const infoTarget = this.#getInfoTarget(this.messageInputTarget)

    const count = input.value.length
    const formattedCount = new Intl.NumberFormat().format(count)

    const pluralRule = new Intl.PluralRules().select(count)
    const template =
      this.characterCountTranslationsValue[pluralRule] ??
      this.characterCountTranslationsValue.other

    infoTarget.textContent = template.replace("%{count}", formattedCount)
  }

  #checkSegments() {
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

  #getInfoTarget(target) {
    return target.querySelector(".input-info span")
  }
}
