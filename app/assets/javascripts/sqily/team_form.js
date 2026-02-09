Sqily.TeamForm = function(node) {
  this.root = node
  this.users = JSON.parse(this.root.dataset.users)
  this.teamates = JSON.parse(this.root.dataset.teamates)
}

Sqily.TeamForm.prototype.addTeamate = function(event) {
  var select = document.getElementById("user-list")
  var userId = parseInt(select.value)
  var newUsers = []

  for (var i = 0; i < this.users.length; i++) {
    if (this.users[i].id == userId)
      this.teamates.push(this.users[i])
    else
      newUsers.push(this.users[i])
  }
  this.users = newUsers
  Barber.render(this)
}

Sqily.TeamForm.prototype.removeTeamate = function(event) {
  var userId = parseInt(event.currentTarget.dataset.userId)
  var newTeamates = []

  for (var i = 0; i < this.teamates.length; i++) {
    if (this.teamates[i].id == userId)
      this.users.push(this.teamates[i])
    else
      newTeamates.push(this.teamates[i])
  }

  this.users.sort(function(a, b) { return a.name < b.name ? -1 : 1 })
  this.teamates = newTeamates
  Barber.render(this)
}
