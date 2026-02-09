Sqily.CommunitySwitch = function(node) {
  node.addEventListener("click", function(event) {
    event.preventDefault();
    document.documentElement.classList.toggle('communitiesopen');
  })
}