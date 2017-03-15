window.R = window.R || {};
window.R.flipflip = (function(window, body, R, undefined) {

  var SELECTOR = ".flipboard .number";

  var F = function() {
    this.addEvents();
  };
    
  F.prototype.addEvents = function() {
      $(SELECTOR).click(function(){
        var $this = $(this);
        $this.hide();
        var $next = $this.next();

        if($next.prop('class') === 'number') {
          $next.show();
        } else {
          $next.parent().find(":first-child").show()
        }

      });
      
  };

  return F;
  
})(window, document.body, window.R);
