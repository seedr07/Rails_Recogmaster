window.R = window.R || {};
window.R.pages = window.R.pages || {};

window.R.pages["home-features"] = (function() {

  var timer = 0;

  var P = function() {
    setTimeout(function() {
      $("#points").removeClass("hidden");
    }, 1000)


    P.superclass.constructor.apply(this, arguments);
  };

  R.utils.inherits(P, R.pages.home);

  return P;
})();

window.R.pages["home-pricing"] = window.R.pages["home-rewards"] = window.R.pages["home-awards"] = (function() {

  var timer = 0;

  var P = function() {
    P.superclass.constructor.apply(this, arguments);
  };

  R.utils.inherits(P, R.pages.home);

  return P;
})();