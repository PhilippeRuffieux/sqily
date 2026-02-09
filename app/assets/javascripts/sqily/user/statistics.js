Sqily.User.Statistics = function(node) {
  new List(node, {valueNames: ["name"]})
}

Sqily.User.Statistics.prototype.filterByTeam = function(event) {
  event.preventDefault()
  var teamId = event.currentTarget.dataset.teamId
  var url = new URL(window.location.href)
  teamId ? url.searchParams.set("team_id", teamId) : url.searchParams.delete("team_id")
  window.location.href = url.toString()
}
