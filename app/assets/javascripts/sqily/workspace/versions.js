Sqily.Workspace.Versions = function(container) {
  Barber.listenEvents(container, this)
}

Sqily.Workspace.Versions.prototype.switchVersion = function(event) {
  var url = event.currentTarget.getAttribute("data-url")
  window.location.href = url.replace("version=version", "version=" + event.currentTarget.value)
}
