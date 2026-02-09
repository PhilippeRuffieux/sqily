window.ModuleLoader = {
  launchWhenDomIsReady: function() {
    if (document.readyState != "loading")
      ModuleLoader.launch();
    else
      document.addEventListener("DOMContentLoaded", ModuleLoader.launch);
  },

  launch: function(root) {
    var elements = (root || document).querySelectorAll("[data-module]");
    Array.prototype.forEach.call(elements, ModuleLoader.start);
  },

  start: function(element) {
    var name = element.getAttribute("data-module");
    var module = ModuleLoader.find(name);
    if (module instanceof Function)
      ModuleLoader.instanciate(module, element)
    else
      console.warn("Module " + name + " is not a function.")
  },

  instanciate: function(module, element) {
    try {
      new module(element);
    } catch (ex) {
      console.error(ex)
    }
  },

  find: function(moduleName) {
    var module = window;
    moduleName.split(".").forEach(function(name) {
      if (!(module = module[name]))
        return null;
    });
    return module;
  }
}
