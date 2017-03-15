(function($, window, body, undefined) {
  var $alert = "<p class='old-browser'>Enhance your online experience and upgrade to a brand new browser! <a href=https://www.google.com/?q=browsers>Please download a new browser</a>.</p>";
  
  function oldBrowser() {
    if (isOldBrowser()) {
      $body.prepend($alert); // Show message at top of browser
    }
  }
  
  function isOldBrowser() {
    return $("#ie").length > 0 && $html.hasClass("ie7");
  }

  return oldBrowser();
  
})(jQuery, window, document.body);