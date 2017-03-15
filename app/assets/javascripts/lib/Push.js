window.R = window.R || {}; 
window.R.Push = (function($, window, body, undefined) {
  var P = function() {
    var script = document.createElement("script");
    var that = this;
    script.src = "http://js.pusher.com/1.12/pusher.min.js";
    $(script).load(function() {
      that.pusher = new Pusher('ee5a4f58e9cca7c82b42');
      that.pusher.companyChannel = that.pusher.subscribe(document.body.getAttribute("data-name"));

      that.noteBar = new window.R.notifications.Bar();
    });
    
    body.appendChild(script);    
  };
  
  P.prototype.ready = function(callback) {
    if (this.ready.readyTimer) {clearTimeout(this.ready.readyTimer);}
    
    if (this.pusher) {
      if (callback) {
        callback();
      }
      return true;
    }
    
    this.ready.readyTimer = setTimeout(this.ready.bind(this, callback), 15);   
  };

  return P;
  
})(jQuery, window, document.body);