Sqily.User = {}

Sqily.User.List = function(element) {
  Barber.listenEvents(this.root = element, this)
  this.infiniteScroll = new InfiniteScroll(element.querySelector("#user-list"), element)
  this.infiniteScroll.subscribe("scroll", function(scroll, element) { Sqily.listenEvents(element) })
}

Sqily.User.List.prototype.search = function(event) {
  var query = event.currentTarget.value
  if (this.oldQuery == query)
    return

  this.oldQuery = query
  var url = event.currentTarget.getAttribute("data-url")
  var request = new XMLHttpRequest()
  request.onload = this.afterSearch.bind(this)
  request.open("GET", updateQueryStringParameter(url, "query", query), true)
  request.setRequestHeader("X-Requested-With", "XMLHttpRequest")
  request.send()
}

Sqily.User.List.prototype.afterSearch = function(event) {
  this.root.querySelector("#user-list").innerHTML = event.target.response
  Sqily.listenEvents(this.root.querySelector("#user-list"))
  this.infiniteScroll.reset()
}
