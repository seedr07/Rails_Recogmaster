(function() {
  window.recognize = window.recognize || {};
  window.recognize.patterns = window.recognize.patterns || {};
  window.recognize.patterns.AccessToken = AccessToken;

  function AccessToken(token) {
    this.token = token || "";

    return token;
  };

  AccessToken.prototype.clear = function() {
    recognize.patterns.storage.set("auth", false);
    this.token = "";
  };

})();

