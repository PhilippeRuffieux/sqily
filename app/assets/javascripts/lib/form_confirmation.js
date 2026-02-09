FormConfirmation = function(container) {
  var elements = (container || document).querySelectorAll("form[data-confirmation]");
  for (var i = 0; i < elements.length; i++) {
    elements[i].addEventListener("submit", FormConfirmation.ask)
  }
}

FormConfirmation.ask = function(event) {
  if (!confirm(this.getAttribute("data-confirmation")))
    event.preventDefault()
}
