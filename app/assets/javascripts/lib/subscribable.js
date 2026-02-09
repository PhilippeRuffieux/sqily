Subscribable = function(object) {
  object.publish = Subscribable.publish
  object.subscribe = Subscribable.subscribe
}

Subscribable.subscribe = function(name, callback) {
  this.callbacks || (this.callbacks = {});
  this.callbacks[name] || (this.callbacks[name] = [])
  return this.callbacks[name].push(callback)
};

Subscribable.publish = function(name) {
  if (this.callbacks && this.callbacks[name])
    for (var i = 0; i < this.callbacks[name].length; i++)
      this.callbacks[name][i].apply(undefined, Array.prototype.slice.call(arguments, 1))
}
