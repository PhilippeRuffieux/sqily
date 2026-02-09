Sqily.Evaluation.DraftForm = function(node) {
  var trix = node.querySelector("trix-editor")
  trix.addEventListener("trix-change", this.updateSubmitButtonState.bind(this))
  this.updateSubmitButtonState()
}

Sqily.Evaluation.DraftForm.prototype.updateSubmitButtonState = function(event) {
  this.submitDraftButton.disabled = this.draftContentInput.value.length == 0
  if (!this.submitDraftButton.disabled && !this.formAutoSave)
    this.formAutoSave = new FormAutoSave(this.node)
}
