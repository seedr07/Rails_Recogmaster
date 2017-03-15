(function() {
  window.R = window.R || {};

  window.R.utils = {
    getFile : function(file, callback) {
      var that = this;
      $.ajax({
        url: file,
        dataType: "html",
        success: function(data) {
            callback.apply(that, [data]);
        },
        cache: false
      });
    },

    render : function(data, template, callback) {
      this.getFile(template, function(file) {
        var hbTemplate = Handlebars.compile(file);
        callback(hbTemplate(data));
      });
    },

    queryParams: function(callback) {
      var searchStr = window.location.search
      if(typeof searchStr === "undefined" ||  searchStr === "") {
        return {};
      }

      var obj = this.paramStringToObject(searchStr.slice(window.location.search.indexOf('?') + 1), callback)
      return obj;      
    },

    locationWithNewParams: function(params) {
      var queryObj, url;

      if(typeof(params) === "string") {
        params = this.paramStringToObject(params);
      }

      queryObj = window.R.utils.queryParams();
      for(var key in params) {
        queryObj[key] = params[key];
      }
      queryParams = $.param(queryObj);

      url = window.location.pathname + "?" + queryParams;

      if(window.location.hash !== "")
        url += window.location.hash;

      // window.location = url;
      return url;

    },
    
    guid: function() {
      return (S4() + S4() + "-" + S4() + "-4" + S4().substr(0,3) + "-" + S4() + "-" + S4() + S4() + S4()).toLowerCase();
    },

    paramStringToObject: function(paramString, callback) {
      // PETE - 2015-06-10
      // This algorithm is pretty terrible, as I'm starting to hack it up
      // We should probably look to replace this
      var obj = {},
            hashes = decodeURIComponent(paramString).split('&');

      for(var i = 0; i < hashes.length; i++)
      {
          // split on = but not == because of base64
          // TODO: there has to be a better way, but because of the 2nd '='
          // character negation class, the first letter of value will go away
          // with the split, so i bring it back by wrapping it in a group
          // and join it up later
          paramArray = hashes[i].split(/=([^=])/);
          
          if(paramArray[1]) // if there is a value
            paramArray = [paramArray[0], paramArray[1]+paramArray[2]]
          else
            paramArray = [paramArray[0].split(/=/)[0], ""]

          if(callback){
            paramArray = callback(paramArray[0], paramArray[1]);
          }
          obj[paramArray[0]] = paramArray[1];
      }
      return obj;
    },

    inherits: function(subClass, superClass) {
      var F = function() {};
      F.prototype = superClass.prototype;
      subClass.prototype = new F();
      subClass.prototype.constructor = subClass;
      
      subClass.superclass = superClass.prototype;
      if (superClass.prototype.constructor === Object.prototype.constructor) {
        superClass.prototype.constructor = superClass;
      }
    },

    installFirefox: function(e) {
      var el = e.target;
      var params;
      e.preventDefault();

      params = {
        "Recognize": {
          URL: el.href,
          IconURL: el.getAttribute("data-iconURL"),
          toString: function () { return this.URL; }
        }
      };

      InstallTrigger.install(params);

      return false;
    }
    
  };

  function S4() {
    return (((1+Math.random())*0x10000)|0).toString(16).substring(1);     
  }

})();
