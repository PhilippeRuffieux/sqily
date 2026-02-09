Sqily.App = function(node) {
  Sqily.App.instance = this
  node.addEventListener("infinite-scroll", function(event) {
    Ariato.listenEvents(event.target, this)
  }.bind(this))
}

Sqily.App.prototype.loadSideBar = function(event) {
  event.preventDefault()
  var url = event.currentTarget.getAttribute("href") || event.currentTarget.getAttribute("data-url")
  var request = new XMLHttpRequest()
  request.open("GET", url, true)
  request.onload = function() {
    this.sidebar.innerHTML = request.response
    Sqily.listenEvents(this.sidebar)
    this.openSidebar()
  }.bind(this)
  request.send()
}

Sqily.App.prototype.openSidebar = function() {
  document.documentElement.classList.add("sidebar-open")
}

Sqily.App.prototype.toggleSidebar = function(event) {
  event && event.preventDefault()
  document.documentElement.classList.toggle("sidebar-open")
}

Sqily.App.prototype.closeSidebar = function(event) {
  event && event.preventDefault()
  document.documentElement.classList.remove("sidebar-open")
}

Sqily.App.prototype.filterByTeam = function(event) {
  this.sidebar.contains(event.currentTarget) && this.loadSideBar(event)
}
