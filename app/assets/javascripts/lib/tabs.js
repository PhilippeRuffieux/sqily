window.Tabs = function(container) {
  container.module = this
  this.root = container
  var buttons = container.querySelectorAll("[data-open-tab]");
  Array.prototype.forEach.call(buttons, function(button) {
    button.addEventListener("click", function(event) {
      this.switchTo(button)
    }.bind(this));
  }.bind(this));
}

Tabs.prototype.switchTo = function(button) {
  Tabs.closeAll(this.root)
  var tab = this.root.querySelector(button.getAttribute("data-open-tab"))
  button.classList.add("active")
  tab.style.display = null
}

Tabs.closeAll = function(container) {
  var buttons = container.querySelectorAll("[data-open-tab]");
  Array.prototype.forEach.call(buttons, function(button) {
    var tab = container.querySelector(button.getAttribute("data-open-tab"));
    button.classList.remove("active");
    tab.style.display = "none";
  });
}
