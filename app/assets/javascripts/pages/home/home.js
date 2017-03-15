window.R = window.R || {};
window.R.pages = window.R.pages || {};

window.R.pages.home = (function($, window, undefined) {
  var isIndexPage = false;

  var isFirstTimeShowingPassword = true;

  var H = function() {
    var $passwordWrapper = $("#password-wrapper"), $balanceText = $('.balance-text');

    if ( $balanceText.length > 0 ) {
      $balanceText.balanceText();
    }

    this.$formsSections = $(".home-form");
    this.$forms = this.$formsSections.find("form");

    isIndexPage = $("#home-index").length > 0;

    this.svgAnimate = new window.R.patterns.AnimateSVGOpacity("#intro svg");

    this.addEvents();

    this.turnOnPasswordToggle();

    setTimeout(function() {
      $(".animate-hidden").removeClass("animate-hidden");
    }, 500);

    $(".scrollToItem").on(R.touchEvent, function(e) {
      var $this = $(this);
      var target = $this.attr("href");
      e.preventDefault();
      $("html, body").animate({
        scrollTop: $(target).offset().top - 200
      });
    });

    this.goToAnchorIfItIsThere();

  };

  H.prototype.goToAnchorIfItIsThere = function() {
    var hash = window.location.hash, offset;

    if (!hash.length) {
      return;
    }

    offset = $(hash).offset().top;

    $("html, body").animate({
      scrollTop: (offset - 30) +"px"
    });
  };

  H.prototype.turnOnPasswordToggle = function() {
    var $passwordWrapper = $("#password-wrapper");
    if ($passwordWrapper.hasClass("current")) {
      R.ui.passwordToggle($passwordWrapper, "user_password");
    }
  };

  H.prototype.targetElementOffset = function () {

    var cache = this.targetElementOffset.cache || 0;
    var $action = $("#action h3");

    if (cache === 0) {
      if ($action.length > 0) {
        cache = $("#action h3").offset().top-100;
      } else {
        cache = 1;
      }
    }

    return (this.targetElementOffset.cache = cache);
  }

  H.prototype.addEvents = function() {
    var that = this;

    $body.bind("view:change", function(e, to) {
      if (to === "#password-wrapper" && isFirstTimeShowingPassword) {
        that.turnOnPasswordToggle();
      }
    });

    $("#new_user").submit(function(e) {
      e.preventDefault();
    });

    $(window).bind("ajaxify:success", function(e, SAFEvent) {
      var isPersonalAccount = SAFEvent.data.company.domain === "users";
      setNextForm(SAFEvent);
      next.call(that, $("#"+SAFEvent.event.target.id).closest(".home-form") , isPersonalAccount);
    });

    this.$forms.submit(function(e) {
      e.preventDefault();
    });

  };

  H.prototype.removeEvents = function() {
    $("#new_user").unbind();
    $body.unbind("view:change");
  };

  function next(current, isPersonalAccount) {
    var id = current.attr("id");

    reset.call(this);

    if (id === "banner" ) {
      R.transition.slide("#banner", "#full_name-wrapper");
      setTimeout(function() {
        $("#user_first_name").focus();
      }, 1000);

    } else {
      R.transition.slide("#full_name-wrapper", "#password-wrapper");
      setTimeout(function() {
        $("#user_password").focus();
      }, 1000);
    }
  }

  function reset() {
    $("html, body").animate({
      scrollTop: this.targetElementOffset()
    });

    $("input").blur();

    $window.focus();
  }

  function setNextForm(SAFEvent) {
    $(".hidden-email").val(SAFEvent.data.user.email);
    if (SAFEvent.event.target.id === "new_user") {
      $("#full_name_attributes_name").val(SAFEvent.data.company.name);
    }
  }

  return H;
})(jQuery, window);