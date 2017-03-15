

(function() {
  var BASE_ENDPOINT;
  window.recognize = window.recognize || {};
  window.recognize.patterns = window.recognize.patterns || {};
  window.recognize.patterns.Api = Api;

  //TODO - make this dynamic somehow(local, staging, production)

  function Api() {
    BASE_ENDPOINT = window.recognize.host+'/api/v1';
    window.recognize.patterns.Api.endPoint = BASE_ENDPOINT;
  };

  Api.prototype.get = function(endpoint, data, options) {
    return this.request(endpoint, 'GET', data, options);
  };

  Api.prototype.post = function(endpoint, data, options) {
    options = options || {};
    options.contentType = "application/json";
    data = JSON.stringify(data);
    return this.request(endpoint, 'POST', data, options);
  };

  Api.prototype.request = function(endpoint, type, data, _options) {
    var requesting = recognize.ajax({
      url: BASE_ENDPOINT + endpoint,
      type: type,
      data: data
    });

    requesting.then(this.done.bind(this), this.failed.bind(this));

    return requesting;

  };

  Api.prototype.done = function() {
    console.log('Request has finished');
  };

  Api.prototype.failed = function(data) {
    switch (true) {
      case /^5/.test(data.status):
        this.failed500(data);
        break;
      case /^400/.test(data.status):
        this.badRequest(data);
        break;
      case /^401/.test(data.status):
        this.unauthenticated(data);
        break;
      case /^403/.test(data.status):
        this.unauthorized(data);
        break;
      case /^404/.test(data.status):
        this.pageNotFound(data);
        break;
      case /^4/.test(data.status):
        this.clientError(data);
        break;
      default:
        this.unknownFailure(data);
        break;
    }
  };

  Api.prototype.failed500 = function(data) {
    console.error('Request has failed due to a server error', data);
  };

  // Client side bug(eg bad parameter)
  Api.prototype.badRequest = function(data) {
    console.error('Request was malformed', data.responseText);
  };

  // User is not logged in 
  Api.prototype.unauthenticated = function(data) {
    if (window.recognize.accessToken) {
      window.recognize.accessToken.clear();
    }
    window.recognize.utils.showAuthorizationHeader();
    console.error('You must authenticate to perform this request', data);
  };

  // User is logged in but does not have the proper credentials
  Api.prototype.unauthorized = function(data) {
    console.error('You do not have the proper privileges for this request', data);
  };

  Api.prototype.pageNotFound = function(data) {
    console.error('That page was not found', data);
  };

  // All other client errors: perhaps a timeout?
  Api.prototype.clientError = function(data) {
    console.error('Request has failed for an unknown reason', data);
  };

  // Everything else
  Api.prototype.unknownFailure = function(data) {
    console.error('Request has failed for an unknown reason', data);
  };

})();
