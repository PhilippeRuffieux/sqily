Sqily.EvalutionForm = function() {
  var buttons = document.querySelectorAll("[data-action=reject-homework]");
  Array.prototype.forEach.call(buttons, function(button) {
    button.addEventListener("click", function(event) {
      if (this.form.querySelector("#comment").value.length == 0) {
        event.preventDefault();
        this.form.querySelector("[data-comment-is-mandatory]").style.display = null;
      }
    });
  });

  var forms = document.querySelectorAll("[data-homework-evaluation]");
  Array.prototype.forEach.call(forms, function(form) {
    form.addEventListener("keypress", function(event) {
      if (event.keyCode == 13) // 13 == enter
        event.preventDefault();
    });
  });
}
