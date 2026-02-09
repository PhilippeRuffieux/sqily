Sqily.Skill.TaskEditor = function(element) {
  this.root = element
  this.tasks = JSON.parse(element.getAttribute("data-json"))
  this.tasks.forEach(function(task) { task.uuid = uuidv4() })
}

Sqily.Skill.TaskEditor.prototype.addTask = function(event) {
  var input = this.root.querySelector("#new-task-title")
  if (input.value.length) {
    this.tasks.push({title: input.value, position: this.tasks.length + 1, uuid: uuidv4()})
    Barber.render(this)
    this.root.querySelector("#new-task-title").focus()
  }
}

Sqily.Skill.TaskEditor.prototype.deleteTask = function(event) {
  if (!confirm("Êtes-vous sûr?"))
    return
  var uuid = event.currentTarget.getAttribute("data-task-uuid")
  var url = event.currentTarget.getAttribute("data-url")
  if (this.findTask(uuid).id) {
    var request = new XMLHttpRequest()
    request.open("DELETE", url, true)
    request.setRequestHeader("X-CSRF-Token", Sqily.csrfToken())
    request.onload = function(event) { this.afterDelete(event, uuid) }.bind(this)
    request.onerror = this.afterDeleteError.bind(this)
    request.send()
  } else
    this.removeTask(uuid)
}

Sqily.Skill.TaskEditor.prototype.afterDelete = function(event, taskUuid) {
  var request = event.currentTarget
  if (request.status >= 200 && request.status < 400)
    this.removeTask(taskUuid)
  else
    alert("Error")
}

Sqily.Skill.TaskEditor.prototype.removeTask = function(uuid) {
  this.tasks.splice(this.findTaskIndex(uuid), 1)
  Barber.render(this)
}

Sqily.Skill.TaskEditor.prototype.findTaskIndex = function(uuid) {
  return this.tasks.findIndex(function(task) { return task.uuid == uuid })
}

Sqily.Skill.TaskEditor.prototype.findTask = function(uuid) {
  return this.tasks[this.findTaskIndex(uuid)]
}

Sqily.Skill.TaskEditor.prototype.afterDeleteError = function() {
  alert("Error")
}

Sqily.Skill.TaskEditor.prototype.dragTask = function(event) {
  event.currentTarget.style.border = "1px dashed #aaa"
  event.currentTarget.classList.add("dragged")
  event.dataTransfer.setData("text", "Empty")
  this.draggedElement = event.currentTarget
}

Sqily.Skill.TaskEditor.prototype.dropTask = function(event) {
  event.currentTarget.style.border = null
  event.currentTarget.style.opacity = null
  event.currentTarget.classList.remove("dragged")
  var oldIndex = this.findTaskIndex(this.draggedElement.getAttribute("data-task-uuid"))
  var newIndex = this.findTaskIndex(this.droppedElement.getAttribute("data-task-uuid"))
  this.moveTask(this.tasks, oldIndex, newIndex)
  this.computeTaskPositions()
  Barber.render(this)
}

Sqily.Skill.TaskEditor.prototype.dragTaskOver = function(event) {
  if (this.draggedElement == event.currentTarget)
    return
  event.currentTarget.parentElement.insertBefore(this.draggedElement, event.currentTarget)
  this.droppedElement = event.currentTarget
}

Sqily.Skill.TaskEditor.prototype.draggedTask = function() {
  if (this.draggedElement)
    return this.findTask(this.draggedElement.getAttribute("data-task-uuid"))
}

Sqily.Skill.TaskEditor.prototype.moveTask = function (array, oldIndex, newIndex) {
  if (newIndex >= array.length) {
    var k = newIndex - array.length
    while ((k--) + 1)
        array.push(undefined)
  }
  array.splice(newIndex, 0, array.splice(oldIndex, 1)[0])
  return array
}

Sqily.Skill.TaskEditor.prototype.computeTaskPositions = function() {
  for (var i = 0; i < this.tasks.length; i++)
    this.tasks[i].position = i + 1
}

Sqily.Skill.TaskEditor.prototype.newTaskTitleChanged = function(event) {
  if (event.keyCode == 13) {
    event.preventDefault()
    this.addTask(event)
  }
}
