window.R = window.R || {};

window.R.Pagelet = (function($, window, body, R, undefined) {
  var Pagelet = function() {
    this.addEvents();
  };

  Pagelet.prototype.addEvents = function() {
    $(".pagelet").each(function(index, el){
      this.getPagelet(el);
    }.bind(this));
  };

  Pagelet.prototype.getPagelet = function(pageletDiv) {
    var $pagelet = $(pageletDiv);
    var endpoint = $pagelet.data("endpoint");
    $pagelet.load(endpoint, function(){
      $pagelet.trigger("pageletLoaded");
    });
  }

  return Pagelet;

})(jQuery, window, document.body, window.R);