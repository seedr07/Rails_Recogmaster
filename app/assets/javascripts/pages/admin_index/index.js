window.R = window.R || {};
window.R.pages = window.R.pages || {};

window.R.pages["admin_index-index"] = (function($, window, undefined) {
  return function() {
    this.pagelet = new window.R.Pagelet();

    $("#admin-graph").bind("pageletLoaded", function(){
      var graph = R.ui.graph();
    });
  }
})(jQuery, window);