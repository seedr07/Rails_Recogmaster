window.R = R || {};
window.R.notifications = window.R.notifications || {};

window.R.notifications.Bar = (function($, window, undefined) {
  var $wrapper;
  
  var Bar = function() {
    $wrapper = $("<div id='notification-bars'></div>");
    $body.append($wrapper);
    this.addEvents();
  };
  
  Bar.prototype.addEvents = function() {
    $window.bind("notification:bar:add", function(e, data) {
      this.add(data);
    }.bind(this));
    
    $body.on("click", "#notification-bars .close", this.close);
  };
  
  Bar.prototype.close = function(e) {
    e.preventDefault();
    $(this).closest(".notification-bar-item").remove();
  };
  
  Bar.prototype.add = function(data) {
    R.utils.render(data, "/notifications/notification-bar-item.html", function(html) {
      var $el = $(html);
      $wrapper.append($el).fadeIn();
      $el.addClass("show");
    });
  };
  
  Bar.prototype.hide = function() {};
  
  return Bar;
})(jQuery, window);