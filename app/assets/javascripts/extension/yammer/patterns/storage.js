(function() {
  var storage, localStorageAdapter, cookiesFacade;
  window.recognize = window.recognize || {};
  window.recognize.patterns = window.recognize.patterns || {};
  localStorageAdapter = {
    set: function(key, value) {
      if (!key || !value) {return;}

      if (typeof value === "object") {
        value = JSON.stringify(value);
      }
      window.localStorage["recognizeapp-"+key] = value;
    },
    get: function(key, callback) {
      var value = window.localStorage["recognizeapp-"+key];

      if (!value) {return callback(false);}

      // assume it is an object that has been stringified
      if (value[0] === "{") {
        value = JSON.parse(value);
      }

      callback(value);
      
    }
  };

  cookiesFacade = {
    set: function(key, value) {
      if (typeof value === "object") {
        value = JSON.stringify(value);
      }
      document.cookie = "recognizeapp-"+key+"="+value;
    },
    get: function(key, callback) {
      var c, C, i;
      if(storage){ return storage["recognizeapp-"+key]; }

      c = document.cookie.split('; ');
      storage = {};

      for(i=c.length-1; i>=0; i--){
         C = c[i].split('=');
         storage[C[0]] = C[1];
      }

      callback( storage["recognizeapp-"+key] );
    }
  }

  window.recognize.patterns.storage = window.localStorage ? localStorageAdapter : cookiesFacade;
})();