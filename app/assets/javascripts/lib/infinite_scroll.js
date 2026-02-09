window.InfiniteScroll = function(container, scrollbar, threshold) {
  this.container = container
  this.threshold = threshold || 1000
  this.scrollbar = scrollbar || container
  // this.scrollbar = this.scrollbar == window ? document.querySelector("body") : this.scrollbar

  this.scrollbar.addEventListener("scroll", this.onScroll.bind(this))
  Subscribable(this)
  this.reset()
}

InfiniteScroll.prototype.onScroll = function() {
  if (this.container.scrollHeight - this.container.offsetHeight - this.container.scrollTop < this.threshold)
    this.fetchNextPage()
  if (this.container.scrollTop < this.threshold)
    this.fetchPreviousPage()
}

InfiniteScroll.prototype.fetchNextPage = function() {
  if (!this.nextPageUrl || this.nextPageUrl == "" || this.isFetchingNextPage)
    return

  this.isFetchingNextPage = true

  var request = new XMLHttpRequest()
  request.open("GET", this.nextPageUrl, true)
  request.setRequestHeader("X-Infinite-Scroll", true)
  request.setRequestHeader("X-Requested-With", "XMLHttpRequest")

  request.onload = function() {
    if (request.status >= 200 && request.status < 300) {
      var previousPage = this.container.lastElementChild
      this.container.lastElementChild.insertAdjacentHTML("afterend", request.responseText)
      var newestPage = previousPage.nextElementSibling
      if (newestPage)
        this.nextPageUrl = newestPage.getAttribute("data-next-page-url")
      this.isFetchingNextPage = false
      this.publish("scroll", this, newestPage, request.responseText)
      newestPage.dispatchEvent(new CustomEvent("infinite-scroll", {bubbles: true}))
    }
  }.bind(this)

  request.send()
}

InfiniteScroll.prototype.fetchPreviousPage = function() {
  if (!this.previousPageUrl || this.isFetchingPreviousPage)
    return

  this.isFetchingPreviousPage = true

  var request = new XMLHttpRequest()
  request.open("GET", this.previousPageUrl, true)
  request.setRequestHeader("X-Infinite-Scroll", true)
  request.setRequestHeader("X-Requested-With", "XMLHttpRequest")

  request.onload = function() {
    if (request.status >= 200 && request.status < 300) {
      this.savePosition()
      this.container.firstElementChild.insertAdjacentHTML("beforebegin", request.responseText)
      this.restorePosition()
      var newestPage = this.container.firstElementChild
      this.previousPageUrl = newestPage.getAttribute("data-previous-page-url")
      this.isFetchingPreviousPage = false
      this.publish("scroll", this, newestPage, request.responseText)
    }
  }.bind(this)

  request.send()
}

InfiniteScroll.prototype.reset = function() {
  this.nextPageUrl = this.container.getAttribute("data-next-page-url")
  this.previousPageUrl = this.container.getAttribute("data-previous-page-url")

  if (!this.nextPageUrl) {
    var element = this.container.querySelector("[data-next-page-url]")
    if (element)
      this.nextPageUrl = element.getAttribute("data-next-page-url")
  }

  if (!this.previousPageUrl) {
    var element = this.container.querySelector("[data-previous-page-url]")
    if (element)
      this.previousPageUrl = element.getAttribute("data-previous-page-url")
  }
}

InfiniteScroll.prototype.savePosition = function() {
  this.savedPosition = {scrollHeight: this.container.scrollHeight, scrollTop: this.container.scrollTop}
}

InfiniteScroll.prototype.restorePosition = function() {
  if (this.savedPosition) {
    this.container.scrollTop = this.savedPosition.scrollTop + this.container.scrollHeight - this.savedPosition.scrollHeight
    this.savedPosition = null
  }
}
