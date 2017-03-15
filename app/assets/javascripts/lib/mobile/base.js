(function() {
  
  window.R = window.R || {};
  
  var Mobile = function() {
    setTimeout(function() {
      window.scrollTo(0, 1);
    }, 50);
  };
  
  R.mobile = new Mobile();
})();