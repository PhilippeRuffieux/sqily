Sqily.MessageForm = function(form) {
  this.form = form
  form.addEventListener("submit", this.submit.bind(this))
  this.textArea().addEventListener("keyup", this.onKeyPressed.bind(this))
}

Sqily.MessageForm.prototype.isReadingArchives = function() {
  if (this.isReadingArchivesCache == null) {
    var element = document.querySelector("[data-auto-pull-url]")
    this.isReadingArchivesCache = element && element.getAttribute("data-auto-pull-url") == ""
  }
  return this.isReadingArchivesCache
}

Sqily.MessageForm.prototype.submit = function(event) {
  event.preventDefault();

  if (this.textArea().value.match(/^\s*$/))
    return

  if (this.isReadingArchives()) {
    this.form.submit()
    return
  }

  var request = new XMLHttpRequest();
  request.onload = this.afterSend.bind(this);
  request.onerror = this.afterError.bind(this);
  request.open("POST", this.form.action, true);
  request.setRequestHeader("X-Requested-With", "XMLHttpRequest");
  request.send(new FormData(this.form));
  this.form.reset();
  this.adjustTextheight()
}

Sqily.MessageForm.prototype.afterSend = function(event) {
  var request = event.target;
  var container = document.querySelector("#messages");
  container.lastElementChild.insertAdjacentHTML("afterend", request.responseText);
  var emptyMessages = document.querySelector("#messages-empty");
  emptyMessages && emptyMessages.parentNode.removeChild(emptyMessages);
  Sqily.listenEvents(container.lastElementChild);
  scrollAncestorsToBottom(container)
}

Sqily.MessageForm.prototype.afterError = function(event) {
}

Sqily.MessageForm.prototype.onKeyPressed = function(event) {
  if (event.keyCode == 13) {  // 13 == Enter
      event.preventDefault()
      if (!event.shiftKey && !event.altKey && !event.ctrlKey)
        this.submit(event)
      else if (event.altKey || event.ctrlKey)
        this.insertString("\n")
  }
  this.adjustTextheight()
}

Sqily.MessageForm.prototype.adjustTextheight = function() {
  var area = this.textArea();
  area.style.height = "auto"
  area.style.height = area.scrollHeight + "px"
}

Sqily.MessageForm.prototype.textArea = function() {
  return this.form.querySelector("#message_text")
}

Sqily.MessageForm.prototype.insertString = function(string) {
  var text = this.textArea()
  var start = text.selectionStart
  var end = text.selectionEnd
  var oldValue = text.value
  text.value = oldValue.substring(0, start) + string + oldValue.substring(end)
  text.setSelectionRange(start + string.length, start + string.length)
  text.focus()
}
