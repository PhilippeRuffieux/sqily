Sqily.Message.SearchForm = function(element) {
  Barber.listenActions(this.root = element, this)
  Barber.listenEvents(this.root, this)
}

Sqily.Message.SearchForm.prototype.close = function() {
  document.getElementById("sidebar-content").classList.remove("sidebar__content--search")
}

Sqily.Message.SearchForm.prototype.submit = function(event) {
  event.preventDefault()
  var form = this.root.querySelector("form")
  var query = this.input().value

  if (query.length < 1)
    return

  this.storeCurrentTab()
  var request = new XMLHttpRequest()
  request.onload = this.afterSend.bind(this)
  //request.onerror = this.afterError.bind(this)
  request.open("GET", form.action + "?query=" + query, true)
  request.setRequestHeader("X-Requested-With", "XMLHttpRequest")
  request.send()
  document.getElementById("search-form-results").classList.add("hidden")
  document.getElementById("search-spinner").classList.remove("spinner--hidden")
}

Sqily.Message.SearchForm.prototype.afterSend = function(event) {
  this.root.querySelector("#search-form-results").innerHTML = event.target.response
  document.getElementById("search-form-results").classList.remove("hidden")
  document.getElementById("search-spinner").classList.add("spinner--hidden")
  ModuleLoader.launch(this.root)
  this.restoreCurrentTab()
}

Sqily.Message.SearchForm.prototype.input = function(event) {
  return this.root.querySelector("[name=query]")
}

Sqily.Message.SearchForm.prototype.storeCurrentTab = function() {
  var tab = document.querySelector('[data-open-tab="#tab-search-files"]')
  if (tab && tab.classList.contains("active"))
    this.currentTabId = "tab-search-files"
  else
    this.currentTabId = "tab-search-messages"
}

Sqily.Message.SearchForm.prototype.restoreCurrentTab = function() {
  if (this.currentTabId == "tab-search-files") {
    this.tabs().module.switchTo(document.querySelector('[data-open-tab="#tab-search-files"]'))
  }
}

Sqily.Message.SearchForm.prototype.tabs = function() {
  return this.root.querySelector("[data-module=Tabs]")
}
