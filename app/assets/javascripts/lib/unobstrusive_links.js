UnobstrusiveLinks = function(container) {
  var links = (container || document).querySelectorAll("a[data-method], [data-confirmation]")
  Array.prototype.forEach.call(links, function(link) { link.addEventListener("click", UnobstrusiveLinks.click) })
}

UnobstrusiveLinks.click = function(event) {
  if (UnobstrusiveLinks.confirm(event))
    UnobstrusiveLinks.method(event)
}

UnobstrusiveLinks.confirm = function(event) {
  var message = event.currentTarget.getAttribute("data-confirmation")
  if (message && !confirm(message)) {
    event.preventDefault()
    return false
  }
  return true
}

UnobstrusiveLinks.method = function(event) {
  if (!event.currentTarget.getAttribute("data-method"))
    return

  event.preventDefault()

  var form = document.createElement("form")
  form.setAttribute("action", event.currentTarget.getAttribute("href"))
  form.setAttribute("method", "post")

  var method = document.createElement("input")
  method.setAttribute("name", "_method")
  method.setAttribute("type", "hidden")
  method.value = event.currentTarget.getAttribute("data-method")
  form.appendChild(method)

  var token = document.createElement("input")
  token.setAttribute("name", Sqily.csrfParam())
  token.setAttribute("type", "hidden")
  token.value = Sqily.csrfToken()
  form.appendChild(token)

  document.body.appendChild(form)
  form.submit()
}
