MultilinePlaceholder = function(element) {
  element.placeholder = element.placeholder.replace(/\\n/g, '\n')
}
