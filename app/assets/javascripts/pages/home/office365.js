window.R = window.R || {};
window.R.pages = window.R.pages || {};

window.R.pages["home-office365"] = (function($, window, undefined) {
  var O = function() {
    this.addEvents();
  };

  O.prototype = {
    auth: function() {
      var key = "sharepointNewUser";
     createCookie(key, "true")
      // localStorage[key] = true;
      var timer = window.setInterval(function(){
        if(!readCookie(key)) {
          clearInterval(timer);
          window.location = "https://"+window.location.host + window.location.search;
        }
      }, 500)
    },

    addEvents: function() {
      $document.on(R.touchEvent, "a.o365-auth-link", this.auth);
    },

    removeEvents: function() {
      $document.off(R.touchEvent, "a.o365-auth-link");
    }
  };

  
  return O;
})(jQuery, window);