Sqily.Evaluation.Switcher = function(node) {
  node.addEventListener("change", function(event) {
    var url = event.currentTarget.value
    replaceNodeFromUrl(document.querySelector("#current-evaluation"), url)
    var input = document.querySelector("#evaluation_draft_evaluation_id")
    input && (input.value = url.split("/").pop())
  })
}

function replaceNodeFromUrl(node, url) {
  var request = new XMLHttpRequest()

  request.onload = function(event) {
    var request = event.target
    if (request.status >= 200 && request.status < 400) {
      node.insertAdjacentHTML("afterend", request.response)
      node.parentElement.removeChild(node)
    }
  }

  request.open("GET", url, true)
  request.setRequestHeader("X-Requested-With", "XMLHttpRequest")
  request.send()
}
