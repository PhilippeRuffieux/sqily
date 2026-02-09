Sqily.Mentions = function(input) {
  var tribute = new Tribute({collection: [
    {
      trigger: "#",
      values: Sqily.Mentions.normalizeData(input.getAttribute("data-hash-tags").split(",")),
    }, {
      trigger: "@",
      lookup: "name",
      fillAttr: "name",
      values: JSON.parse(input.getAttribute("data-user-names"))
    },
  ]}).attach(input);
}

Sqily.Mentions.normalizeData = function(array) {
  return array.map(function(name) {
    return {key: name, value: name};
  });
}
