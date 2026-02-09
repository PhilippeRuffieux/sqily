function autoScrollToBottom() {
  Array.prototype.forEach.call(document.querySelectorAll("[data-auto-scroll-to-bottom]"), scrollToBottom);
}

function scrollToBottom(element) {
  if (element.scrollTop != null)
    element.scrollTop = element.scrollHeight;
}

function scrollAncestorsToBottom(element) {
  if (element) {
    scrollToBottom(element)
    scrollAncestorsToBottom(element.parentElement)
  }
}
