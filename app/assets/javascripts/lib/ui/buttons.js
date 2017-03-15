window.R = window.R || {};
window.R.ui = window.R.ui || {};
window.R.ui.Buttons = (function($, window, body, undefined) {

  var b = function() {
    //pretty sure almost all of buttons.js can go bye
    //$(".bootstrap-check li input:checked").next(".button").addClass("button-primary").removeClass("button-inactive").find("i").removeClass("opacity0");
    //$(".bootstrap-check label input:checked").next(".button").addClass("button-primary").removeClass("button-inactive").find("i").removeClass("opacity0");
    this.addEvents();
  };

  b.prototype.addEvents = function() {
    // TODO: refactor
    
    // This is for when only one button can be highlighted.
    $body.on(R.touchEvent, ".bootstrap-toggle-check li .button", function(e) {
      var $this = $(this);
      e.preventDefault();

      $(".bootstrap-toggle-check li .button i").addClass("opacity0");
      $(".bootstrap-toggle-check li .button").removeClass("button-primary");

      if ($this.hasClass("button-primary")) {
        $this.siblings("input").removeAttr("checked");
        $this.closest(".thumbnail").removeClass("selected");
        $this.find("i").addClass("opacity0");
      } else {
        $(".bootstrap-toggle-check li .button").removeClass("button-primary");
        $this.addClass("button-primary");
        $this.find(".thumbnail").addClass("selected");
        $this.siblings("input").attr("checked", "checked");
        $this.find("i").removeClass("opacity0");
      }
    });

    // This is for when many buttons can have active state.
    $body.on(R.touchEvent, ".bootstrap-check .button", function(e) {
      var $this = $(this);
      e.preventDefault();

      if ($this.hasClass("button-primary")) {
        $this.removeClass("button-primary").addClass("button-inactive");
        $this.siblings("input").removeAttr("checked");
        $this.closest(".thumbnail").removeClass("selected");
        $this.find("i").addClass("opacity0");

      } else {
        
        $(".bootstrap-toggle-check li .button").removeClass("button-primary");
        $this.addClass("button-primary").removeClass("button-inactive");
        $this.find(".thumbnail").addClass("selected");
        $this.siblings("input").attr("checked", "checked");
        $this.find("i").removeClass("opacity0");
      }
    });

    $body.on(R.touchEvent, ".button-group .button", function() {
      var $this = $(this);
      if (!$this.hasClass("button-pressed")) {
        $(".button-group .button").removeClass("button-pressed");
        $this.addClass("button-pressed");
        $body.focus();
      }
    });
  };

  b.prototype.removeEvents = function() {
    $body.off(R.touchEvent, ".button-group .button");
    $body.off(R.touchEvent, ".bootstrap-check .button");
    $body.off(R.touchEvent, ".bootstrap-toggle-check li .button");
  };

  return b;
})(jQuery, window, document.body);