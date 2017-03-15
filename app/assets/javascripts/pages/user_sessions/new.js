window.R = window.R || {};
window.R.pages = window.R.pages || {};

window.R.pages["user_sessions-new"] = window.R.pages["user_sessions-create"] = (function() {
  var U = function() {
    $(function() {
      $("#view-main-wrapper .login-wrapper").removeClass("login-hide");
    });

  };

  return U;

})();