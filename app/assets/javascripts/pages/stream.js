window.R = window.R || {};
window.R.pages = window.R.pages || {};

window.R.pages["recognitions-index"] = (function($, window, body, R, undefined) {
  
  var Stream = function() {    
    this.$container = $('#stream');
    this.recognitionCards = new R.Cards( this.$container, function() {
      $("#stream").removeClass("opacity0");
    });
    
    this.addEvents();
    
    this.buttons = new R.ui.Buttons();

    this.checkFromSharepointForFirstTime();
  };

  Stream.prototype.checkFromSharepointForFirstTime = function() {
    var key = "sharepointNewUser";

    if (readCookie(key)) {
      swal({
        title: "Success!<br>You logged in from Sharepoint",
        text: "Please close this tab to return to Sharepoint",
        imageUrl: "/assets/pages/home-office365/sharepoint-icon-big.png",
        html: true
      });
      // delete localStorage[key];
      eraseCookie(key);
    }
  };
  
  Stream.prototype.addEvents = function() {
    var $container = this.$container;
    var timer = 0;
    var tappedRecognitionCard = null;

    $document.bind("page:fetch", this.removeEvents.bind(this));
    
    $("#sort-popular").bind(R.touchEvent, function() {
      $container.isotope({ sortBy : 'popular', sortAscending: false });
    });
    
    $("#sort-latest").bind(R.touchEvent, function() {
      $container.isotope({ sortBy : 'original-order', sortAscending: true });
    });
    
    $document.on(R.touchEvent, "#column-switch", this.toggleDetails.bind(this));
  };


  Stream.prototype.toggleDetails = function(e) {
    var $details = $("#recognition-details");
    var text = "View details";
    e.preventDefault();
    $details.toggleClass("block");
    $("#stream").toggleClass("displayNone");
    this.addResGauge();
    $("#latest-popular-buttons").toggleClass("displayNone");

    if ($details.hasClass("block")) {
      text = "Close details";
    }

    $(e.target).text(text);
  };

  Stream.prototype.removeEvents = function() {
    delete this.$container;
    delete this.recognitionCards;
    $document.off(R.touchEvent, "#column-switch");
  };
  
  return Stream;
})(jQuery, window, document.body, window.R);