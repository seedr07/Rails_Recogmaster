window.R = window.R || {};
window.R.pages = window.R.pages || {};

window.R.pages["home-about"] = window.R.pages["home-engagement"] = window.R.pages["home-analytics"] = window.R.pages["home-gamification"] = (function($, window, undefined) {
  var T = function() {
    T.superclass.constructor.apply(this, arguments);
  };
  
  R.utils.inherits(T, R.pages.home);
  
  return T;
})(jQuery, window);