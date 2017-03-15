window.R = window.R || {};

window.R.IdpRedirecter = (function($, window, body, R, undefined) {
  var IdpRedirecter = function() {
    this.addEvents();
  };  

  IdpRedirecter.prototype.addEvents = function() {
    $document.on('blur', "body:not(#identity_providers-show) .user-session-email", function(){
      var $field = $(this);
      $field.addClass('loading');
      var email = $field.val();
      $.ajax({
        url: "/idp_check",
        data: {email: email},
        complete: function(data){
          var idpUrl = data.responseJSON.idp_url;
          if(idpUrl) {
            $(".user-session-password").prop('disabled', true);
            Turbolinks.visit(idpUrl); 
          } else {
            $field.removeClass('loading');
          }
        }
      });
    });
  };

  return IdpRedirecter;
})(jQuery, window, document.body, window.R);