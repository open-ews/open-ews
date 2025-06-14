import * as tabler from "@tabler/core"
import moment from "moment"
import TomSelect from "tom-select"

const initializeLocalTime = (scope) => {
  scope
    .querySelectorAll("time[data-behavior~=local-time]")
    .forEach((element) => {
      element.textContent = moment(element.textContent).format("lll (Z)")
    })
}

const initializeBootstrapComponents = (scope) => {
  scope.querySelectorAll('[data-bs-toggle="tooltip"]').forEach((element) => {
    new tabler.bootstrap.Tooltip(element)
  })

  scope.querySelectorAll('[data-bs-toggle="popover"]').forEach((element) => {
    new tabler.bootstrap.Popover(element)
  })
}

const initializeTomSelectElement = (scope, selector, options = {}) => {
  scope.querySelectorAll(selector).forEach((element) => {
    if (!element.tomselect) {
      new TomSelect(element, options)
    }
  })
}

const initializeTomSelect = (scope) => {
  initializeTomSelectElement(scope, "select.list-select")
  initializeTomSelectElement(scope, "select.input-tags", { create: true })
  initializeTomSelectElement(scope, "select.input-tags-readonly", {
    plugins: ["no_backspace_delete"],
    create: false,
    persist: false,
    onItemAdd: () => false,
    onDelete: () => false,
  })
}

const initializeJSComponents = (scope = document) => {
  initializeLocalTime(scope)
  initializeBootstrapComponents(scope)
  initializeTomSelect(scope)
}

// Store target on event detail temporarily
addEventListener("turbo:before-stream-render", (event) => {
  const streamElement = event.target
  const target = streamElement.getAttribute("target")
  event.detail.streamTarget = target
})

// Initialize on page load and navigation (full document scope)
const events = ["turbo:load", "turbo:render"]
events.forEach((event) =>
  document.addEventListener(event, () => initializeJSComponents())
)

// ======== Initialize JS Components After Turbo Stream Render ========
document.addEventListener("turbo:before-stream-render", (event) => {
  const originalRender = event.detail.render

  event.detail.render = function (streamElement) {
    originalRender(streamElement)

    // Dispatch the custom event with the target element
    const customEvent = new CustomEvent("turbo:after-stream-render", {
      detail: { target: event.detail.streamTarget },
    })
    document.dispatchEvent(customEvent)
  }
})

// Initialize components after turbo stream renders
document.addEventListener("turbo:after-stream-render", (event) => {
  const { target } = event.detail
  const targetElement = document.getElementById(target)

  if (targetElement) {
    initializeJSComponents(targetElement)
  }
})
