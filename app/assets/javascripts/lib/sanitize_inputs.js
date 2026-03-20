window.sanitizeInputs = function(container) {
  var inputs = (container || document).querySelectorAll("input[data-sanitize]");
  for (var i = 0; i < inputs.length; i++) {
    var input = inputs[i];
    input.addEventListener("blur", sanitizeInput);
  }
};

function sanitizeInput(event) {
  var input = event.target;
  var mode = input.getAttribute("data-sanitize");
  if (mode === "parameterize")
    input.value = parameterize(input.value);
  else if (mode === "strip")
    input.value = input.value.trim().replace(/\s+/g, " ");
}

function parameterize(value) {
  return value
    .trim()
    .toLowerCase()
    .normalize("NFD").replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9\s-]/g, "")
    .replace(/[\s_]+/g, "-")
    .replace(/-+/g, "-")
    .replace(/^-|-$/g, "");
}
