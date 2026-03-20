addEventListener("trix-before-initialize", function () {
  Trix.config.textAttributes.highlight = {
    tagName: "mark",
    inheritable: true
  }
})

addEventListener("trix-initialize", function (event) {
  var toolbar = event.target.toolbarElement
  var boldButton = toolbar.querySelector("[data-trix-attribute=bold]")
  if (!boldButton) return
  var buttonGroup = boldButton.closest(".trix-button-group")

  var button = document.createElement("button")
  button.setAttribute("type", "button")
  button.setAttribute("class", "trix-button trix-button--icon trix-button--icon-highlight")
  button.setAttribute("data-trix-attribute", "highlight")
  button.setAttribute("title", "Highlight")
  button.setAttribute("tabindex", "-1")
  button.textContent = "Highlight"
  buttonGroup.appendChild(button)
})
