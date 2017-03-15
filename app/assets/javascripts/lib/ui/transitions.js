window.R = window.R || {};

R.Transition = (function() {
  var toEl, fromEl;
  var animationEvent = "animationend webkitAnimationEnd animationend oAnimationEnd";
  var isSliding = false;

  var Transition = function() {
    this.$wrapper = $(document.body);
    this.addEvents();
  }

  Transition.prototype.addEvents = function() {
    this.$wrapper = $(document.body),
    that = this;

    $document.on("animation:started", function() {
      $body.addClass("transition-animating");
    });

    $document.on("animation:complete", function() {
      $body.removeClass("transition-animating");
    });

    $document.on("page:restore", function() {
      this.$wrapper = $(document.body);
    }.bind(this));    
    
    this.$wrapper.on(animationEvent, ".in", function() {
      $(this).removeClass("slide in reverse");
      isSliding = false;
      $document.trigger("animation:complete");
    });
        
    this.$wrapper.on(animationEvent, ".out", function() {
      $(this).removeClass("current out slide reverse");
      $document.trigger("animation:complete");
    });

    this.$wrapper.on(R.touchEvent, ".slideable-trigger", function(e) {
      var $this = $(this);

      if(!$this.data('allowLink')) {
        e.preventDefault();        
      }

      if (isSliding) {
        return;
      }

      if ( $($this.data("to")).hasClass("current") ) {
        return false;
      }

      that.slide($this.data("from"), $this.data("to"), $this.data("direction"));
    });

    $document.on(R.touchEvent, ".fadeTop .close-icon", function(event) {
      event.preventDefault();
      this.fadeTop();
    }.bind(this));

    $window.keyup(function(e) {
      if (e.keyCode === 27 && $(".fadeTop.current").length > 0) {
        this.fadeTop();
      }
    }.bind(this));

    $document.bind("page:fetch", this.removeEvents.bind(this));
  };

  Transition.prototype.removeEvents = function() {
    $document
      .off(R.touchEvent, ".fadeTop .close-icon")
      .off("animation:complete")
      .off("animation:started");

    this.$wrapper
      .off(R.touchEvent, ".slideable-trigger")
      .off(animationEvent, ".out")
      .off(animationEvent, ".in");

    $window.unbind("keyup");
  };
    
  Transition.prototype.slide = function(from, to, direction) {
    $document.trigger("animation:started");

    toEl = to;
    fromEl = from;
    isSliding = true;
    
    if (!direction) {
      direction = '';
    }
    
    if (!Modernizr.cssanimations) {
      $(".slideable").removeClass("current");
      $(to).addClass("current");
      isSliding = false;
    } else {
      $(from).addClass("slide out "+direction);
      $(to).addClass("slide current in "+direction);
    }
    
    $body.trigger("view:change", to);

    $("html, body").animate({
      scrollTop: $(to).offset().top - 100
    });
  };
  
  Transition.prototype.fadeTop = function(element) {
    var $element = $(element);
    $document.trigger("animation:started");

    if ($element[0] === $(".fadeTop.current")[0]) {
      return;
    }
    if (!Modernizr.cssanimations) {
      $(".fadeTop.current").removeClass("current out in");
    } else {
      $(".fadeTop.current").addClass("out");
      $("body.overlay-open").removeClass("overlay-open");
    }
    
    if (element) {
      $("body").addClass("overlay-open");
      $(element).addClass("current");
    }

    if (window.outerWidth && window.outerWidth <= 600) {
      this.$wrapper.scrollTop(1);
    }



  };
    
  Transition.prototype.show = function(from, to) {
    if (from) {
      $(from).removeClass("current out");
      $(to).addClass("current");
    } else {
      $(to).addClass("current");
    }
    
    $body.trigger("view:change", to);
  };
    
  return Transition;
})();
