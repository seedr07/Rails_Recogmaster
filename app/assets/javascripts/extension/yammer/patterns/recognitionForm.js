(function() {
  window.recognize = window.recognize || {};
  window.recognize.patterns = window.recognize.patterns || {};
  window.recognize.patterns.recognitionForm = {
    open: open,
    close: recognize.patterns.overlay.close
  };

  var template;

  function open(yammerId, message) {
    var that = this;

    template = template || Handlebars.compile(jQuery('#r-iframe').html());

    getModalURL(yammerId, message, function(data) {

     var iframeHTML = template({
      url: data.url,
      id: 'r-recognition-new-iframe'
    });

     recognize.patterns.overlay.open(window.recognize.patterns.i18n().send_recognition, iframeHTML);
   });

  }

  function getModalURL(yammerId, message, callback) {
    var url = '/recognitions/new', params = {};

    if (yammerId) {
      params["yammer_id"] = yammerId
    }

    if (message) {
      params["message"] = message
    }

    if( yammerId || message) {
      url = url + "?" + jQuery.param(params)      
    }
    
    var gettingModalUrl = window.recognize.patterns.api.get(url);
    gettingModalUrl.done(callback);
  }
})();
