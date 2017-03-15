window.R = window.R || {};
window.R.pages = window.R.pages || {};

window.R.pages["signups-welcome"] = (function() {
  
  var Welcome = function() {
    this.invite = new window.R.pages["users-invite"]();
    this.teams = new window.Teams.Inline();
    this.addEvents();
    this.buttons = new window.R.ui.Buttons();
    if ($body.width() < 480) {
      setTimeout(function() {
        $body.animate({
            scrollTop: $(".welcome-buttons").offset().top
         }, 500);
      }, 1000);
    }
  };
  
  Welcome.prototype.addEvents = function() {
    var $body = $(document.body);
    
    $body.on(R.touchEvent, "#name .welcome-buttons .trigger", this.submitName.bind(this));
    $body.on(R.touchEvent, "#teams .trigger", function(e) {
      e.preventDefault();
      $(this).closest("form").submit();
    });

        
    $body.bind('view:change', function (e, el) {
      $(".steps li").removeClass("current");
      $(el.replace("#", ".")).addClass("current");
    });
  };
  
  Welcome.prototype.submitName = function(e) {
    var $nameNotice = $("#name .notice");
    var $el = $(e.target);
    var isNextButton = $el.hasClass("button-highlight");
    e.preventDefault();
    
    if ($("#user_first_name").val() === "" || $("#user_last_name").val() === "") {
      $nameNotice.hide();
      
      return $("#name .form-errors").show();
    } else {
      $nameNotice.show();
      
      $(".steps-wrapper .form-errors").hide();
      $(".message-important").hide();
    
      if (isNextButton) {
        R.transition.slide("#name", "#teams");
      } else {
        $el.closest("form").submit();
      }
    }
  };

  return Welcome;

})();

// TODO remove hack
window.R.pages["signups-welcome"] = window.R.pages["signups-welcome"];