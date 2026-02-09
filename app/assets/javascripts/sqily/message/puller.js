Sqily.Message = {}

Sqily.Message.Puller = function (container) {
  this.container = container;
  this.url = container.getAttribute("data-auto-pull-url");
  if (this.url && this.url != "")
    setTimeout(this.fetch.bind(this), this.interval = Sqily.Message.Puller.DEFAULT_INTERVAL);
}

Sqily.Message.Puller.DEFAULT_INTERVAL = 5000;

Sqily.Message.Puller.prototype.fetch = function() {
  var request = new XMLHttpRequest();
  request.open("GET", this.url, true);
  request.setRequestHeader("X-Auto-Puller", true);
  request.setRequestHeader("X-Requested-With", "XMLHttpRequest");
  request.setRequestHeader("Accept", "application/json");
  request.onload = this.onSuccess.bind(this);
  request.onerror = this.onError.bind(this);
  request.send();
}

Sqily.Message.Puller.prototype.onSuccess = function(event) {
  var request = event.target
  if (request.status == 200 && request.responseText) {
    var json = JSON.parse(request.responseText)
    var shouldScrollToBottom = this.isScrollAtBottom()
    this.updateEditedMessages(json["edited_messages"])
    this.updateSkillsWithUnreadMessages(json["skill_ids_with_unread_messages"])
    this.updateNewMessages(json["new_messages"])
    if (json["next_url"])
      this.url = json["next_url"]
    if (shouldScrollToBottom)
      scrollAncestorsToBottom(this.container)
  }
  this.interval = request.status == 200 ? Sqily.Message.Puller.DEFAULT_INTERVAL : Math.min(60000, this.interval * 2);
  setTimeout(this.fetch.bind(this), this.interval);
}

Sqily.Message.Puller.prototype.onError = function() {
  setTimeout(this.fetch.bind(this), this.interval = Math.min(60000, this.interval * 2));
}

Sqily.Message.Puller.prototype.updateNewMessages = function(html) {
  if (html) {
    var lastChild = this.container.lastElementChild;
    this.container.lastElementChild.insertAdjacentHTML("afterend", html);
    var newLastChild = lastChild.nextElementSibling;
    Sqily.listenEvents(newLastChild)

    this.container.querySelectorAll("[data-remove-after-pull]").forEach(function(el) {
      el.parentNode.removeChild(el)
    })
  }
}

Sqily.Message.Puller.prototype.updateEditedMessages = function(editedMessages) {
  if (!editedMessages)
    return
  editedMessages.forEach(function(message) {
    var oldMarkup = document.querySelector("#message-" + message.id);
    oldMarkup && (oldMarkup.outerHTML = message.html);
    var newMarkup = document.querySelector("#message-" + message.id);
    Sqily.listenEvents(newMarkup)
  });
}

Sqily.Message.Puller.prototype.updateSkillsWithUnreadMessages = function(ids) {
  if (ids && ids.forEach) {
    ids.forEach(function(id, index) {
      var skill = document.querySelector('[data-skill-id-activity="' + id + '"]');
      skill && skill.classList.add("unread-messages");
    });
  }
}

Sqily.Message.Puller.firstScrollableAncestor = function(element) {
  if (element) {
    return element.scrollHeight > element.offsetHeight ? element : Sqily.Message.Puller.firstScrollableAncestor(element.parentElement)
  }
}

Sqily.Message.Puller.prototype.isScrollAtBottom =  function() {
  var element = Sqily.Message.Puller.firstScrollableAncestor(this.container)
  return element && (element.scrollTop + element.offsetHeight) == element.scrollHeight
}
