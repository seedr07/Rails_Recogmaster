window.recognize = window.recognize || {};
window.recognize.utils = window.recognize.utils || {};

window.recognize.utils.getParameterByName = function( name, href ) {
  name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
  var regexS = "[\\?&]"+name+"=([^&#]*)";
  var regex = new RegExp( regexS );
  var results = regex.exec( href );
  if( results == null )
    return "";
  else
    return decodeURIComponent(results[1].replace(/\+/g, " "));
}

window.recognize.utils.showAuthorizationHeader = function() {
  recognize.patterns.toolbar.create(false);
};