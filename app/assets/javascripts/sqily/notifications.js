Sqily.Notifications = function(container) {
  this.infiniteScroll = new InfiniteScroll(container)
  this.infiniteScroll.subscribe("scroll", function(scroll, element) { Sqily.listenEvents(element) })
}
