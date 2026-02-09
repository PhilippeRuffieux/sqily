Sqily.State = function(container) {
  setTimeout(this.fetch.bind(this), this.interval = 20 * 1000);
  this.container = container
}

Sqily.State.prototype.fetch = function() {
  var url = this.container.getAttribute("data-url")
  var request = new XMLHttpRequest()
  request.open("GET", "/base-secrete/state", true)
  request.setRequestHeader("X-Requested-With", "XMLHttpRequest")
  request.onload = this.update.bind(this)
  request.send()
  setTimeout(this.fetch.bind(this), this.interval);
}

Sqily.State.prototype.update = function(event) {
  var response = JSON.parse(event.target.response)
  this.updateNotifications(response)
  this.updateUsers(response)
}

Sqily.State.prototype.updateUsers = function(json) {
  var icons = document.querySelectorAll("[data-online-status]")
  for (var i = 0; i < icons.length; i++) {
    var userId = parseInt(icons[i].getAttribute("data-online-status"))
    icons[i].style.display = json.active_user_ids.includes(userId) ? null : "none"
  }
}

Sqily.State.prototype.updateNotifications = function(json) {
  var counter = document.getElementById("unread-notification-count")
  counter.style.display = json.unread_notification_count > 0 ? null : "none"
  counter.textContent = json.unread_notification_count
}
