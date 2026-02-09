Sqily.Skill = {}

Sqily.Skill.DescriptionTabs = function(container) {
  this.container = container
  Barber.listenEvents(this.container, this)

  Array.prototype.forEach.call(this.all(), function(tab) {
    tab.addEventListener("click", this.switchTab.bind(this))
  }.bind(this));

  if (this.container.getAttribute("data-show-tasks") == "true")
    this.switchTab(document.querySelector("[data-skill-description-tab=skill-tasks]"))
}

Sqily.Skill.DescriptionTabs.prototype.all = function() {
  return this.container.querySelectorAll("[data-skill-description-tab]")
}

Sqily.Skill.DescriptionTabs.prototype.switchTab = function(event) {
  var tab = event.currentTarget || event
  var active = !tab.classList.contains("skill__description__tab--active")
  var tabValue = tab.getAttribute("data-skill-description-tab")

  this.hideAll()

  Array.prototype.forEach.call(document.querySelectorAll("#skill-description [data-skill-description-tab-content]"), function(content) {
    var hidden = !content.classList.contains("tab-content--hidden")
    var tabContent = content.getAttribute("data-skill-description-tab-content")
    if (tabValue == tabContent)
      content.classList.toggle("tab-content--hidden")
    else
      content.classList.add("tab-content--hidden")
  })
  active && tab.classList.add("skill__description__tab--active") && content.classList.remove("tab-content--hidden")
}

Sqily.Skill.DescriptionTabs.prototype.hideAll = function(event) {
  Array.prototype.forEach.call(this.all(), function(tab) {
    tab.classList.remove("skill__description__tab--active")
  })
}
