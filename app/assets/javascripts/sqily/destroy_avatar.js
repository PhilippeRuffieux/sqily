Sqily.DestroyAvatar = {
  listen: function() {
    var button = document.querySelector("[data-action=destroy-avatar]");
    button && button.addEventListener("click", function(event) {
      event.preventDefault();
      var url = this.getAttribute("href");
      var request = new XMLHttpRequest();
      request.open("DELETE", url, true);
      request.setRequestHeader("X-CSRF-Token", Sqily.csrfToken());
      request.onload = function() { document.querySelector("#current-user-avatar").remove(); }
      request.send();
    });
  },
}
