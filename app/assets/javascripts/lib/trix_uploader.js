TrixAttachment = function(element) {
  this.config = JSON.parse(element.getAttribute("data-attachment-config"))
  element.addEventListener("trix-attachment-add", function(event) {
    var attachment = event.attachment;
    attachment.file && this.upload(attachment);
  }.bind(this))
}

TrixAttachment.prototype.upload = function(attachment) {
  var form = new FormData
  var key = this.config.key + Math.random().toString().substr(2, 6) + "/" + attachment.file.name
  form.append("key", key)
  form.append("AWSAccessKeyId", this.config.AWSAccessKeyId)
  form.append("policy", this.config.policy)
  form.append("signature", this.config.signature)
  form.append("acl", this.config.acl)
  form.append("file", attachment.file);
  var xhr = new XMLHttpRequest;
  xhr.open("POST", this.config.host, true);

  xhr.upload.onprogress = function(event) {
    if (event.total > 0)
      return attachment.setUploadProgress(event.loaded / event.total * 100);
  }

  xhr.onload = function() {
    if (xhr.status === 204) {
      var url = this.config.host + key
      return attachment.setAttributes({url: url, href: url})
    }
  }.bind(this)

  return xhr.send(form);
}

