Sqily.InputFileName = function(container) {
  this.input = document.querySelector(container.getAttribute("data-target"))
  this.input.addEventListener("change", this.showFileName.bind(this))
  this.container = container
}

Sqily.InputFileName.prototype.showFileName = function(event) {
  var fileName = '';
  if( this.input.files && this.input.files.length > 1)
  	fileName = (this.getAttribute('data-multiple-caption') || '').replace('{count}', this.files.length)
  else
  	fileName = event.target.value.split( '\\' ).pop()

  if(fileName)
    this.container.innerHTML = fileName
}
