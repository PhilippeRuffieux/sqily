Sqily.Skill.TaskList = function(element) {
  Barber.listenActions(this.root = element, this)
}

Sqily.Skill.TaskList.prototype.toggleTask = function(event) {
  var request = new XMLHttpRequest();
  request.open("POST", event.currentTarget.getAttribute("data-url"), true);
  request.setRequestHeader("X-CSRF-Token", Sqily.csrfToken())
  var input = event.currentTarget

  request.onload = function() {
    if (request.status >= 200 && request.status < 400)
      input.parentElement.classList.toggle("label--checked")
    else
      alert("Error")
    document.getElementById("evaluations-container").style.display = this.done() ? null : "none"
    document.getElementById("task-list-instructions").style.display = this.done() ? "none" : null
    this.updateCounter()
  }.bind(this)

  request.onerror = function() { alert("Netwrok error") }

  request.send()
}

Sqily.Skill.TaskList.prototype.done = function() {
  return this.checkBoxes().length == this.countDoneTasks()
}

Sqily.Skill.TaskList.prototype.updateCounter = function() {
  var counter = document.getElementById("doneTaskCounter")
  counter.innerHTML = this.countDoneTasks()
}

Sqily.Skill.TaskList.prototype.countDoneTasks = function() {
  var result = 0, inputs = this.checkBoxes()
  for (var i = 0; i < inputs.length; i++)
    if (inputs[i].checked)
      result++
  return result
}

Sqily.Skill.TaskList.prototype.checkBoxes = function() {
  return this.root.querySelectorAll("[data-action=toggleTask]")
}
