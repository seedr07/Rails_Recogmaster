(function() {
  var discount = false;

  function Welcome() {
    this.ppu = 2; // $2/user
    this.yearlyDiscount = 0.1;
    this.addEvents();
  }

  Welcome.prototype.addEvents = function() {
    if (window.InstallTrigger) {
      $document.on(R.touchEvent, "#firefox", R.utils.installFirefox);
    }
    
    $("#user-count-form").on("submit", this.showCountResultPage.bind(this));
    $(".ten-percent-off-trigger").on(R.touchEvent, function() {
      discount = true;
      $(".discount").removeClass("displayNone");

      if (R.youTubeWelcomePlayer) {
        try {
          R.youTubeWelcomePlayer.stopVideo();
        }
        catch(e) {}
      }
    });

    $document.on("animation:started", function() {
      if (R.youTubeWelcomePlayer) {
        try {
          R.youTubeWelcomePlayer.stopVideo();
        }
        catch(e) {}
      }
    });

    $("#payment-form").on("ajaxify:success", this.showCongrats.bind(this));

    $document.on('click', "#subscription-interval-group button", function(evt) {
      this.handleIntervalChange(evt);
    }.bind(this));
  };

  Welcome.prototype.showCongrats = function() {
    R.transition.slide("#user-count-low", "#user-activated", "left");
  };

  Welcome.prototype.showCountResultPage = function(e) {
    var count = $("#user_count").val();
    var price = (count*2*(discount === true ? .9 : 1)).toFixed(2);
    e.preventDefault();

    if (count === 0 || count === "") {
      return;
    }

    R.transition.slide("#user-count", "#user-count-low", "left");

    $("#number-of-users").text(count);
    $("#price-text").text(price);
    $("#quantity").val(count);

    if(discount) {
      $("#coupon").val("tenoff");
    }

    if (count > 300) {
      this.showHighCountPage();
    } else if (count < 300) {
      this.showLowCountPage();
    } else {
      return;
    }
  };

  Welcome.prototype.showHighCountPage = function() {

  };

  Welcome.prototype.showLowCountPage = function() {

  };

  Welcome.prototype.handleIntervalChange = function(evt) {
    evt.preventDefault();
    var $this = $(evt.target);
    var $buttonGroup = $this.parents(".button-group");
    var interval = $this.data('interval');

    $buttonGroup.find("button").removeClass("button-pressed");
    $this.addClass("button-pressed");
    $("#subscription-interval").val(interval);

    var count = $("#user_count").val();

    if(interval == 4){ // yearly
      var price = (count * this.ppu * 12 * (1 - this.yearlyDiscount)).toFixed(2);
      $("#price-text").text(price);
      $("#interval-text").text("/yr");
      $("#price-subheading").text("Includes 10% off");

    } else { //monthly
      var price = (count * this.ppu).toFixed(2);
      $("#price-text").text(price);
      $("#interval-text").text("/mo");
      $("#price-subheading").text("");
    } 
  };

  Welcome.prototype.removeEvents = function() {
    if (R.youTubeWelcomePlayer) {
      try {
        R.youTubeWelcomePlayer.stopVideo();
      }
      catch(e) {}
    }

    $("#user-count-form").off("submit");
    $(".ten-percent-off-trigger").off(R.touchEvent);
    $document.off('click', "#subscription-interval-group button");
  };

  window.R = window.R || {};
  window.R.pages = window.R.pages || {};
  window.R.pages["welcome-show"] = Welcome

})();
