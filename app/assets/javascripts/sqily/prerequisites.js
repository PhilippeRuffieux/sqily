Sqily.Prerequisites = function(container) {
  Sqily.Prerequisites.addEventListeners(container);
}

Sqily.Prerequisites.addEventListeners = function(container) {
  var elements = container.querySelectorAll("[data-delete-prerequisite]");
  Array.prototype.forEach.call(elements, function(element) {
    element.addEventListener("click", Sqily.Prerequisites.delete);
  });

  var elements = container.querySelectorAll("[data-toggle-prerequisite-mandatory]");
  Array.prototype.forEach.call(elements, function(element) {
    element.addEventListener("click", Sqily.Prerequisites.toggleMandatory);
  });

  var addButton = container.querySelector("#add-prerequisite");
  addButton && addButton.addEventListener("click", Sqily.Prerequisites.add);
}

Sqily.Prerequisites.delete = function(event) {
  var request = new XMLHttpRequest();
  request.open("DELETE", this.getAttribute("data-url"), true);
  request.setRequestHeader("X-CSRF-Token", Sqily.csrfToken());
  request.send();
  document.querySelector(this.getAttribute("data-delete-prerequisite")).remove();
}

Sqily.Prerequisites.toggleMandatory = function(event) {
  var request = new XMLHttpRequest();
  request.open("PATCH", this.getAttribute("data-url"), true);
  request.setRequestHeader("X-CSRF-Token", Sqily.csrfToken());
  request.send();
  this.classList.toggle("active");
}

Sqily.Prerequisites.add = function(event) {
  var request = new XMLHttpRequest();
  request.open("POST", this.getAttribute("data-url"), true);
  request.setRequestHeader("X-CSRF-Token", Sqily.csrfToken());
  request.setRequestHeader("Content-Type", "application/json");
  var data = {prerequisite: {from_skill_id: document.querySelector("#new-prerequisite").value}};
  request.onload = function() {
    if (request.status >= 200 && request.status < 400) {
      var list = document.querySelector("#prerequisite-list");
      list.lastElementChild.insertAdjacentHTML("beforebegin", request.response);
      Sqily.Prerequisites.addEventListeners(list.lastElementChild.previousElementSibling);
    }
  };
  request.send(JSON.stringify(data));
  this.classList.toggle("active");
}
