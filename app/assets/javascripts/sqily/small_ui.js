Sqily.SmallUi = {
  initialize: function() {
    Sqily.SmallUi.evaluationsDropdown();
    Sqily.SmallUi.clickOnShareFile();
  },

  evaluationsDropdown: function() {
    var dropdown = document.getElementById("evaluations-dropdown");
    dropdown && dropdown.addEventListener("change", function(event) {
      if (event.currentTarget.value == "all")
        window.location.href = event.currentTarget.selectedOptions[0].getAttribute("data-url");
    });
  },

  clickOnShareFile: function(event) {
    var button = document.querySelector("[data-action='share-file']");
    button && button.addEventListener("click", function(event) {
      document.getElementById("upload_text").value = document.getElementById("message_text").value;
      Sqily.Modal.open("#file-sharing-modal")
    });
  },
}
