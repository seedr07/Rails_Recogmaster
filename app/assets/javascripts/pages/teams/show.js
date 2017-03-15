window.R = window.R || {};
window.R.pages = window.R.pages || {};

window.R.pages["teams-show"] = (function() {
  var gauge = false;
  
  var TeamsShow = function() {
    var timer = 0;
    var $recognitionWrapper = $("#recognitions-wrapper");
    
    if ( $recognitionWrapper.find("li").length > 0) {
      new R.Cards( $("#recognitions-wrapper") );
    }
    
    window.R.ui.remoteOverlay();
    
    $(window).resize(function() {
      clearTimeout(timer);
      timer = setTimeout(function() {
        $body.trigger("recognition:change");
      }, 50);
      
    });

    if ($window.width() > 768) {
      gauge = window.R.gage("#team-res");
    } else {
      $document.on(R.touchEvent, "#column-switch", this.toggleDetails.bind(this));
    }
  };

  TeamsShow.prototype.removeEvents = function() {
    $document.off(R.touchEvent, "#column-switch");
    gauge = false;
  };


  TeamsShow.prototype.toggleDetails = function(e) {
    var $details = $("#team-details");
    var text = "View details";
    e.preventDefault();
    $details.toggleClass("block");
    $(".default-view").toggleClass("displayNone");

    if (!gauge) {
      gauge = window.R.gage("#team-res");
    }

    if ($details.hasClass("block")) {
      text = "Close details";
    }

    $(e.target).text(text);
  };

  return TeamsShow;

})();