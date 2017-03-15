window.R = window.R || {};

window.R.DatePicker = function(callback) {
  if(typeof($.fn.datepicker) === 'function') {
    callback();
  } else {
    $('head').append( $('<link rel="stylesheet" type="text/css" />').attr('href', '/assets/3p/bootstrap-datepicker.css') );
    $.getScript('/assets/3p/bootstrap-datepicker.js', function(){
      callback();
    });      
  }
};