Sqily.Event.Participation = function(container) {
  Barber.listenEvents(container, this)
}

Sqily.Event.Participation.prototype.toggleParticipation = function(event) {
  var url = event.currentTarget.getAttribute("data-url")
  var request = new XMLHttpRequest()
  var element = event.currentTarget
  request.open("POST", url, true)
  request.setRequestHeader("X-CSRF-Token", Sqily.csrfToken())
  request.onload = function(event) {
    if (this.status >= 200 && this.status < 400) {
      participation = JSON.parse(event.target.response)
      element.classList.remove("present")
      element.classList.remove("absent")
      if (participation.confirmed == true)
        element.classList.add("present")
      else if (participation.confirmed == false)
        element.classList.add("absent")
    } else {
      alert("Error")
    }
  }
  request.send()
}
