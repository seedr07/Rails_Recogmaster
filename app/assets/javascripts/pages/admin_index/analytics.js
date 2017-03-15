window.R = window.R || {};
window.R.pages = window.R.pages || {};

window.R.pages["admin_index-analytics"] = (function($, window, undefined) {
  return function() {
    new window.R.flipflip();
    $(".flipboard .show").click(function(){
      var $this = $(this);
      $this.closest(".flipboard").find(".company-list").show();
    });  
    $(".close-company-list").click(function(){
      var $this = $(this);
      $this.closest(".company-list").hide();
    });
    var graph = R.ui.graph();
  }
})(jQuery, window);
