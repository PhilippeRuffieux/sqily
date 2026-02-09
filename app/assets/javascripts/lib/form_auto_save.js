FormAutoSave = function(form) {
  this.form = form
  this.saveRegularly()
  window.addEventListener("beforeunload", this.saveOnExit.bind(this))
}

FormAutoSave.prototype.saveRegularly = function() {
  setTimeout(function() {
    this.saveRegularly()
    this.save()
  }.bind(this), 10 * 1000)
}

FormAutoSave.prototype.saveOnExit = function() {
  var request = new XMLHttpRequest()
  request.open(this.method(), this.url(), false)
  request.send(new FormData(this.form))
}

FormAutoSave.prototype.save = function() {
  var request = new XMLHttpRequest()
  request.open(this.method(), this.url(), true)
  request.send(new FormData(this.form))
}

FormAutoSave.prototype.url = function() {
  return this.form.getAttribute("action")
}

FormAutoSave.prototype.method = function() {
  return this.form.getAttribute("method").toUpperCase()
}
