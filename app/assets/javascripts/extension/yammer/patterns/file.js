(function() {
  window.recognize = window.recognize || {};
  window.recognize.patterns.File = File;

  function File() {};

  File.prototype.getPath = function(file) {
    return window.recognize.host+"/assets/extension/yammer/"+file;
  };

  File.prototype.load = function(path) {
    var div = jQuery("<div>");
    div.load(window.recognize.file.getPath(path))
    $body.append(div);
  }
  
})();

