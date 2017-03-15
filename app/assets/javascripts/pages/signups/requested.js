window.R = window.R || {};
window.R.pages = window.R.pages || {};

window.R.pages["signups-requested"] = (function($, window, undefined) {

  var S = function() {
   this.addEvents()
  };  

  S.prototype.addEvents = function() {
    var $btn = $("#interested-btn");
    $btn.on('click', function(){
      $.ajax({
        url: "/signup/personal_interest",
        type: "POST",
        data: {email: $btn.data('id'), interested: 'yes'},
        complete: function(){
          $("#survey-wrapper").hide();
          $("#complete").show();
        }
      });
    })
  };

  return S;
})(jQuery, window);
