window.R = window.R || {};
window.R.pages = window.R.pages || {};

window.R.pages["badges-show"] = (function() {
  
  var BadgesShow = function() {
    this.$container = $('#stream');
    this.recognitionCards = new R.Cards( this.$container, function() {
      $("#stream").removeClass("opacity0");
    } );

  };

  return BadgesShow;

})();