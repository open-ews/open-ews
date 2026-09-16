import { Controller } from "@hotwired/stimulus"
import { SegmentedMessage } from "sms-segments-calculator"

export default class extends Controller {
  static targets = [
    "channelInput",
    "audioFileInput",
    "messageInput",
    "beneficiaryGroupsInput",
    "beneficiaryFiltersContainer",
  ]

  static values = {
    messageSegmentWarningThreshold: Number,
    characterCountTranslations: Object,
    deliverableChannels: Array,
    audioChannels: Array,
    textChannels: Array,
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
    const channel = this.channelInputTarget.value

    const isAudio = this.audioChannelsValue.includes(channel)
    const isText = this.textChannelsValue.includes(channel)
    const isDeliverable = this.deliverableChannelsValue.includes(channel)

    this.#toggleTarget(this.audioFileInputTarget, isAudio)
    this.#toggleTarget(this.messageInputTarget, isText)
    this.#toggleTarget(this.beneficiaryGroupsInputTarget, isDeliverable)

    if (this.hasBeneficiaryFiltersContainerTarget) {
      this.beneficiaryFiltersContainerTarget.hidden = !isDeliverable

      // Dispatch event to let child controllers sync their own enabled/disabled states
      this.beneficiaryFiltersContainerTarget.dispatchEvent(
        new Event("change", { bubbles: true }),
      )
    }
  }

  #toggleTarget(wrapperTarget, enable) {
    if (!wrapperTarget) return
    wrapperTarget.hidden = !enable

    const input = wrapperTarget.querySelector("input, textarea, select")
    if (input) input.disabled = !enable
  }

  #updateCharacterCount() {
    const input = this.#messageInput
    const infoTarget = this.messageInputTarget.querySelector(".input-info span")
    if (!input || !infoTarget) return

    const count = input.value.length
    const pluralRule = new Intl.PluralRules().select(count)
    const template =
      this.characterCountTranslationsValue[pluralRule] ??
      this.characterCountTranslationsValue.other

    infoTarget.textContent = template.replace(
      "%{count}",
      new Intl.NumberFormat().format(count),
    )
  }

  #checkSegments() {
    const input = this.#messageInput
    const warningTarget =
      this.messageInputTarget.querySelector(".input-warning")
    if (!input || !warningTarget) return

    const segments = new SegmentedMessage(input.value).segmentsCount
    warningTarget.hidden = segments <= this.messageSegmentWarningThresholdValue
  }

  get #messageInput() {
    return this.hasMessageInputTarget
      ? this.messageInputTarget.querySelector("input, textarea")
      : null
  }
}
