window.R = window.R || {};

window.R.Select2 = (function($, window, body, R, undefined) {
  var Select2 = function(callback) {
    if(typeof($('select').select2) === 'function') {
      callback();
    } else {
      $('head').append( $('<link rel="stylesheet" type="text/css" />').attr('href', '//cdnjs.cloudflare.com/ajax/libs/select2/4.0.0/css/select2.min.css') );
      $.getScript('//cdnjs.cloudflare.com/ajax/libs/select2/4.0.0/js/select2.min.js', function(){
        callback();
      });      
    }

  };

  return Select2;

})(jQuery, window, document.body, window.R);