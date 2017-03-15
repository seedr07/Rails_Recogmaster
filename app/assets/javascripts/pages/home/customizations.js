window.R = window.R || {};
window.R.pages = window.R.pages || {};

window.R.pages["home-customizations"] = (function($, window, undefined) {
  var T = function() {
    var timer = 0;
    var $analytics;

    $window.scroll(function() {
      clearTimeout(timer);

      timer = setTimeout(function() {
        var $analytics = $analytics || $("#analytics");
        if ($window.scrollTop() > $analytics.offset().top - 690 && !$analytics.hasClass("ready")) {
          $analytics.addClass("ready");
        }
      }, 50);
    });

    T.superclass.constructor.apply(this, arguments);
  };

  T.prototype.removeEvents = function() {
    $window.unbind("scroll");
  };

  R.utils.inherits(T, R.pages.home);

  return T;
})(jQuery, window);