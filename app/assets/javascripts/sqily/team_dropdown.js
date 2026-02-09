Sqily.TeamDropdown = function(node) {
  node.addEventListener("click", function(event) {
    event.preventDefault();
    if (this.ariaExpanded == "true") {
      this.ariaExpanded = "false";
    } else {
      this.ariaExpanded = "true";
    }
  })
}
