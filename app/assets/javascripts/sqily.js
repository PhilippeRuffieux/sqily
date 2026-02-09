window.Sqily = function() {
  this.initializeWhenReady();
}

Sqily.prototype.initialize = function() {
  new Sqily.SkillFilters();
  new Sqily.EvalutionForm();

  autoSubmit();
  autoScrollToBottom();

  var messages = document.getElementById("messages")
  if (messages) {
    var infiniteScroll = new InfiniteScroll(messages)
    infiniteScroll.subscribe("scroll", function(scroll, element) { Sqily.listenEvents(element) })
    messages.addEventListener("scroll", this.updateTopDate);
    this.updateTopDate();
  }

  Sqily.Modal.listenOpener("[data-open-modal]");
  Sqily.Modal.listenCloser("[data-close-modal]");

  Sqily.SmallUi.initialize();

  Sqily.DestroyAvatar.listen();

  new List("skills", {valueNames: ["name"]});

  Sqily.listenEvents(document.documentElement)

}

Sqily.prototype.initializeWhenReady = function() {
  if (document.readyState != "loading")
    this.initialize();
  else
    document.addEventListener("DOMContentLoaded", this.initialize.bind(this));
}

Sqily.prototype.updateTopDate = function() {
  var topDate = document.getElementById("top-date");
  if (!topDate)
    return
  var rect = topDate.getBoundingClientRect();
  var element = document.elementFromPoint(rect.left, rect.bottom + 19);

  while (element && !element.dataset.date)
    element = element.parentElement;

  if (element)
    topDate.innerHTML = element.dataset.date;
}


Sqily.csrfToken = function() {
  return document.querySelector("meta[name=csrf-token]").content
}

Sqily.csrfParam = function() {
  return document.querySelector("meta[name=csrf-param]").content
}

Sqily.listenEvents = function(container) {
  ModuleLoader.launch(container)
  UnobstrusiveLinks(container)
  FormConfirmation(container)
  Barber.launch(container)
  Ariato.launchWhenDomIsReady(container)
  Ariato.initialize(Sqily.App.instance, Sqily.App.instance.sidebar)
}
