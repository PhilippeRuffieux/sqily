UnsavedFormAlert = function (form) {
  this.shouldWarnOnLeaving = true

  form.addEventListener("submit", function (event) {
    this.shouldWarnOnLeaving = false
  }.bind(this));

  Array.prototype.forEach.call(form.getElementsByTagName("input"), function (input) {
    input.addEventListener("input", this.inputChanged.bind(this))
  }.bind(this))

  Array.prototype.forEach.call(form.getElementsByTagName("trix-editor"), function (input) {
    input.addEventListener("trix-change", this.inputChanged.bind(this))
  }.bind(this))
}

UnsavedFormAlert.prototype.inputChanged = function (event) {
  if (this.changed)
    return
  this.changed = true

  window.addEventListener("beforeunload", function (e) {
    if (this.shouldWarnOnLeaving) {
      e.returnValue = "You didn't save the form.";
    }
  }.bind(this))
}
