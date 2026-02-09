Sqily.EditMessage = function(element) {
  element.addEventListener("click", Sqily.EditMessage.prompt.bind(this));
}

Sqily.EditMessage.prompt = function(event) {
  if (this.active)
    return
  this.active = true

  var messageId = event.currentTarget.getAttribute("data-edit-message");
  var text = event.currentTarget.getAttribute("data-message-text");
  var textElement = document.querySelector("#message-text-" + messageId)
  textElement.setAttribute("contenteditable", true)
  textElement.classList.add("message-text-editing")
  textElement.focus()

  var saveId = "save-edit-message-" + messageId;
  var cancelId = "cancel-edit-message-" + messageId;
  textElement.insertAdjacentHTML("afterend", "<span class='btn' id='" + saveId + "'>Enregistrer</span>")
  textElement.insertAdjacentHTML("afterend", "<span class='btn cancel' id='" + cancelId + "'>Annuler</span>")

  var saveButton = document.querySelector("#" + saveId)
  var cancelButton = document.querySelector("#" + cancelId)

  saveButton.addEventListener("click", function(event) {
    textElement.removeAttribute("contenteditable")
    textElement.classList.remove("message-text-editing")
    saveButton.parentElement.removeChild(saveButton)
    cancelButton.parentElement.removeChild(cancelButton)
    Sqily.EditMessage.update(messageId, textElement.innerText)
  }.bind(this))

  cancelButton.addEventListener("click", function(event) {
    this.active = false
    textElement.removeAttribute("contenteditable")
    textElement.classList.remove("message-text-editing")
    saveButton.parentElement.removeChild(saveButton)
    cancelButton.parentElement.removeChild(cancelButton)
  }.bind(this))
}

Sqily.EditMessage.update = function(messageId, text) {
  var url = "/" + window.location.pathname.split("/")[1] + "/messages/" + messageId;
  var request = new XMLHttpRequest();
  request.open("PATCH", url, true);
  request.onload = function() {
    if (request.status == 200) {
      var selector = "#message-" + messageId
      document.querySelector(selector).outerHTML = request.response;
      Sqily.listenEvents(document.querySelector(selector))
    }
  }
  request.setRequestHeader("X-Requested-With", "XMLHttpRequest");
  request.setRequestHeader("X-CSRF-Token", Sqily.csrfToken());
  var data = new FormData();
  data.append("message[text]", text);
  request.send(data);
}
