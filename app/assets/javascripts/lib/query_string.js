// Taken from http://stackoverflow.com/questions/5999118/add-or-update-query-string-parameter
function updateQueryStringParameter(uri, key, value) {
  var separator = uri.indexOf("?") !== -1 ? "&" : "?";
  var regex = new RegExp("([?&])" + key + "=.*?(&|$)", "i");
  if (uri.match(regex))
    return uri.replace(regex, "$1" + key + "=" + value + "$2");
  else
    return uri + separator + key + "=" + value;
}
