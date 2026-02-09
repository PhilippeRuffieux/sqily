TimePicker = function(element) {
  var options = element.getAttribute("data-time-picker")
  flatpickr(element, this.buildOptions(JSON.parse(options)))
}

TimePicker.prototype.defaultOptions = function() {
  return {
    enableTime: true,
    time_24hr: true,
    locale: this.defaultLocale(),
  }
}

TimePicker.prototype.defaultLocale = function() {
  return document.documentElement.getAttribute("lang").split("-")[0]
}

TimePicker.prototype.buildOptions = function(options) {
  var result = this.defaultOptions()
  if (options)
    for (var attr in options)
      result[attr] = options[attr]
  return result
}
