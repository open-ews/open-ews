import * as tabler from "@tabler/core"
import moment from "moment"
import TomSelect from "tom-select"

// NOTE: Run javascript after turbo stream has finished replace the DOM
// https://nts.strzibny.name/rails-turbo-after-stream-render/
const afterRenderEvent = new Event("turbo:after-stream-render")
addEventListener("turbo:before-stream-render", (event) => {
  const originalRender = event.detail.render

  event.detail.render = function (streamElement) {
    originalRender(streamElement)
    document.dispatchEvent(afterRenderEvent)
  }
})

const initializeJSComponents = () => {
  ;[].slice
    .call(document.querySelectorAll("time[data-behavior~=local-time]"))
    .forEach(function (element) {
      element.textContent = moment(element.textContent).format("lll (Z)")
    })
  ;[].slice
    .call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
    .forEach((element) => new tabler.bootstrap.Tooltip(element))
  ;[].slice
    .call(document.querySelectorAll("select.list-select"))
    .forEach((element) => new TomSelect(element))
  ;[].slice
    .call(document.querySelectorAll("select.input-tags"))
    .forEach((element) => new TomSelect(element, { create: true }))
  ;[].slice
    .call(document.querySelectorAll("select.input-tags-readonly"))
    .forEach(
      (element) =>
        new TomSelect(element, {
          plugins: ["no_backspace_delete"],
          create: false,
          persist: false,
          onItemAdd: () => false,
          onDelete: () => false,
        })
    )
}

;["turbo:load", "turbo:after-stream-render"].forEach((e) =>
  document.addEventListener(e, initializeJSComponents)
)
