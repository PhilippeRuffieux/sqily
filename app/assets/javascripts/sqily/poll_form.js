Sqily.PollForm = function(element) {
  element.querySelector("#add-poll-choice").addEventListener("click", this.addChoice)
}

Sqily.PollForm.prototype.addChoice = function(event) {
  var list = document.querySelector("#poll-choices")
  var newChoice = document.querySelector('#poll-choice-template').cloneNode(true)
  newChoice.querySelector('[data-action="remove-choice"]').addEventListener("click", function() {
    list.removeChild(newChoice)
  })
  newChoice.style.display = null
  newChoice.removeAttribute("id")
  list.appendChild(newChoice)
}
