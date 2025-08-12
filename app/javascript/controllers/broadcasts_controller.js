import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="broadcasts"
export default class extends Controller {
  connect() {
    this.toggleChannel()
  }

  toggleChannel() {
    const element = this.channelInputTargets.find((element) => element.checked)

    if (element.value == "voice") {
      this.voiceChannelTargets.forEach(
        (target) => (target.style.display = "block")
      )
      this.smsChannelTargets.forEach(
        (target) => (target.style.display = "none")
      )
    } else if (element.value == "sms") {
      this.smsChannelTargets.forEach(
        (target) => (target.style.display = "block")
      )
      this.voiceChannelTargets.forEach(
        (target) => (target.style.display = "none")
      )
    }
  }
}
