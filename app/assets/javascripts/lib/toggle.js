Toggle = {}

Toggle.Css = function(element) {
  element.addEventListener("click", this.run)
}

Toggle.Css.prototype.run = function() {
  var css = this.getAttribute("data-css")
  var selector = this.getAttribute("data-target")
  var targets = selector ? document.querySelectorAll(selector) : [this]
  Array.prototype.forEach.call(targets, function(element) { element.classList.toggle(css) })
}
