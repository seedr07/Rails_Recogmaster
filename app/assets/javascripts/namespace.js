window.R = window.R || {};
window.hasTouch = 'ontouchstart' in window;
R.touchEvent = (hasTouch) ? "tap" : "click";

R.ui = R.ui || {};

R.nameSpace = function() {
  window.body = document.body;
  window.$body = $(document.body);

  window.$window = window.$window || $(window);
  window.$html = window.$html || $("html");
  window.$document = window.$document || $(document);
};

R.nameSpace();