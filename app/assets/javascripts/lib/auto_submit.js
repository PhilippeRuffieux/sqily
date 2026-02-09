window.autoSubmit = function(container) {
  var inputs = (container || document).querySelectorAll("input[data-auto-submit]");
  for (var i = 0; i < inputs.length; i++) {
    var input = inputs[i];
    input.addEventListener("change", input.form.submit.bind(input.form));
  }
};
