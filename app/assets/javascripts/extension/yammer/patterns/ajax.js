(function() {

  window.recognize = window.recognize || {};

  window.recognize.ajax = function(userOptions) {
    var options = {
      xhrFields: {
        withCredentials: true
      },
      crossDomain: true,
      contentType: "text/plain"
    };

    // if (window.recognize.accessToken) {
    //   options.headers = {
    //     'Authorization': 'Bearer ' + window.recognize.accessToken()
    //   }
    // } else {
    //   options.headers = {
    //     'X-Authorization-Cookie-Auth': 'true'
    //   }
    // }

    if( userOptions) {
      jQuery.extend(options, userOptions);      
    }

    return jQuery.ajax(options);
  };
})();
