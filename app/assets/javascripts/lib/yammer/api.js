window.Yammer = (function($, window, body, undefined) {
  var timer = 0;
  
  var API_URL = "https://c64.assets-yammer.com/assets/platform_js_sdk.js";
  
  var BASE_URL = "https://api.yammer.com/api/v1/";

  var authToken = null;

  var Y = function(success, apiKey, failure, _authToken) {

    if (this.isLoggedIn === true && success) {
      success();
    }

    if (typeof _authToken === "undefined") {
      authToken = window.yammerSettings.accessToken || null;
    } else {
      authToken = _authToken;
    }

    this.apiKey = ( apiKey || window.yammerSettings.apiKey ) || null;
    this.isLoggedIn = false;

    var failure = failure || function() {};
    
    $.getScript(API_URL, function() {
        this.login(success);
    }.bind(this));
  };
  
Y.prototype.setAccessToken = function(token, success, failure) {
    clearTimeout(timer);

    token = token || authToken;
    if (!window.yam || !window.yam.platform.request) {
      timer = setTimeout(function() {
        this.setAccessToken(token, success, failure);
      }.bind(this), 100);
    } else {

      yam.config({appId: this.apiKey});
      yam.platform.setAuthToken(token);

      setTimeout(function() { // a sad truth when a timeout fixes the problem
        yam.getLoginStatus(function(r) {
          if (r.access_token === "") {
            this.isLoggedIn = false;
            if (failure) {failure();}
          } else {
            this.isLoggedIn = true;
            if(success) {success();}
          }
        }.bind(this));
      }.bind(this), 150);
    }
  };
  
  Y.prototype.login = function(success, failure) {
    var yammerSettings = window.yammerSettings;
    if (yammerSettings) {
      this.setAccessToken(yammerSettings.accessToken);
    }
  };
  
  Y.prototype.loginDialog = function(success, failure) {
    yam.login( 
    function (response) {
      checkLogin.apply(this, [response, success, failure]);
    },
    function(error) {if(failure) {failure(error);}});
  };
  
  function checkLogin(response, success, failure) {
    if (response.authResponse) {
      this.isLoggedIn = true;   
      if (success) {success(response);}
    } else {
     this.isLoggedIn = false;
     if (failure) {failure(response);}
    }
  }
  
  Y.prototype.endPoints = {
    message: {
      url: BASE_URL+"messages.json",
      method: "POST",
      data: { 
        "og_url": "http://www.recognizeapp.com",
        "og_site_name": "Recognize",
        "og_description": "Motivating the workplace through social recognition."
      }
    },
    users: {
      url: BASE_URL+"users.json", 
      method: "GET"
    },
    getCurrentUserGroups: {
      url: BASE_URL+"groups.json?mine=1",
      method: "GET"
    },
    groups: {
      url: BASE_URL+"users/in_group/{{id}}.json",
      method: "GET"
    },
    currentUser: {
      url: BASE_URL+"users/current.json",
      method: "GET"
    },
    activity: {
      url: BASE_URL+"activity.json",
      method: "POST"
    },
    autocomplete: {
      url: BASE_URL+'autocomplete/ranked',
      method: 'GET'
    }
  };
  
  Y.prototype.api = function(options) {
    var params = Y.prototype.endPoints[options.endPoint];
    params.data = params.data || {};
    
    var data = options.data;
    
    if (data) {
      for (var item in data) {
        if (data.hasOwnProperty(item)) {
          params.data[item] = data[item];
        }
      }
    }
    
    params.success = options.success || function() {};
    params.failure = options.failure || function() {};
    request.call(this, params);    
  };
  
  function request(params) {
    
    if (authToken) {
      var yamRequest = yam.platform.request(params);
      yamRequest.complete(function(obj, status) {
        if (status === "error" && typeof params.failure !== "undefined") {
          params.failure();
        }
      });
    } else {
      yam.getLoginStatus(function() {
        yam.platform.request(params);
      });
    }
  }
  
  Y.prototype.postMessage = function(data, success, failure) {
    if (data.image) {
      data.og_image = data.image;
    }
    
    if (data.message) {
      data.body = '"'+data.message+'"';
    }
    
    delete data.image;
    delete data.content;
    
    data.og_title = data.title;
        
    this.api({
      endPoint: "message",
      success: success,
      failure: failure,
      data: data
    });
  };
  
  Y.prototype.getUsers = function(success, failure) {
    this.api({
      endPoint: "users",
      success: success,
      failure: failure
    });
  };
  
  Y.prototype.getCurrentUserGroups = function(success, failure) {
    this.api({
      endPoint: "getCurrentUserGroups",
      success: success,
      failure: failure
    });
  };
  
  Y.prototype.currentUser = function(success, failure) {
    this.api({
      endPoint: "currentUser",
      success: success,
      failure: failure
    });
  };
  
  Y.prototype.getGroupById = function(id, success, failure) {
    this.endPoints.groups.url = this.endPoints.groups.url.replace("{{id}}", id);
    this.api({
      endPoint: "groups",
      success: success,
      failure: failure
    });
  };
  
  Y.prototype.activity = function() {
    
  };
  
  Y.prototype.autocomplete = function(term, limit, response, failure){
    this.api({
      endPoint: "autocomplete",
      data: {
        prefix: term,
        models: 'user:' + limit          
      },
      success: response,
      failure: failure
    });
  };

  Y.prototype.getUser = function(id, displayCallback) {
        // old, needs fixin!!
        var options = {
          url: '/api/v1/users/' + id,
          method: 'GET',
          success: function(yammerData){
            user = _.first(translator.translateUsers([yammerData]));
            displayCallback(user);
          }
        };

        yam.platform.request(options);

  } ; 
  return Y;
})(jQuery, window, document.body);