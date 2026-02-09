Sqily.Modal = {
  listenOpener: function(element_or_selector) {
    var elements = Sqily.Modal.normalizeToElementsArray(element_or_selector);
    for (var i = 0; i < elements.length; i++)
      elements[i].addEventListener("click", Sqily.Modal.triggerOpening);
  },

  listenCloser: function(element_or_selector) {
    var elements = Sqily.Modal.normalizeToElementsArray(element_or_selector);
    for (var i = 0; i < elements.length; i++)
      elements[i].addEventListener("click", Sqily.Modal.triggerClosing);
  },

  normalizeToElementsArray: function(element_or_selector) {
    if (typeof(element_or_selector) == "string")
      return document.querySelectorAll(element_or_selector);
    else if (!Array.isArray(element_or_selector))
      return [element_or_selector];
    else
      return element_or_selector;
  },

  triggerOpening: function(event) {
    var modal, target;
    if (target = event.currentTarget.getAttribute("data-open-modal"))
      Sqily.Modal.open(target);
  },

  triggerClosing: function(event) {
    var modal, target;
    if (target = event.currentTarget.getAttribute("data-close-modal"))
      Sqily.Modal.close(target);
  },

  open: function(selector) {
    var modal = document.querySelector(selector);
    var overlay = document.querySelector("#modal-overlay");
    if (modal) {
      modal.style.display = null;
      overlay && (overlay.style.display = null);
    }
  },

  close: function(selector) {
    var modal = document.querySelector(selector);
    var overlay = document.querySelector("#modal-overlay");
    if (modal) {
      modal.style.display = "none";
      overlay && (overlay.style.display = "none");
    }
  },
}
