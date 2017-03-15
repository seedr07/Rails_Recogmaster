window.Autocomplete = (function(window, undefined) {
  var cachedResultsHash = {};
  var currentUserEmail = $body.data("email");
  
  var A = function(config) {
    var $input = $(config.input), options;
    config.$input = $input;
    this.createUsers = config.createUsers || true;
        
    options = this.extendOptions(config);
    
    $.widget("custom.recognizeAutoComplete", $.ui.autocomplete, window.Autocomplete.recognizeAutocomplete());
    $input.recognizeAutoComplete(options);

    $window.unload(function() {
      cachedResultsHash = null;
    });

    if ($html.hasClass("ie9")) {
      $input.click(function() {
        $(this).val("");
      });
    }

    // load Yammer autocomplete
    if (this.createUsers && window.yammerSettings && window.yammerSettings.accessToken) {
      window.R.y = new window.Yammer();
    }

    $document.bind("page:fetch", function() {
      cachedResultsHash = {};
      $input = null;
    });
  };
  
  A.prototype.extendOptions = function(config) {
    var extendedOptions = window.Autocomplete.options;
    
    var options = {
      minLength: 1,
      delay: 50,
      autoFocus: true,
      appendTo: config.appendTo || "#recognition-new-autocomplete-wrapper",
      select: function(evt, ui) {
        var item = ui.item;
        var email = item["email"];

        var successOpts = {
          avatar_thumb_url: item.avatar_thumb_url,
          name: item.label || email,
          id: item.id,
          email: email,
          type: item.type
        };

        // Add recognition api
        if(item.web_url) {
          successOpts.web_url = item.web_url;
        }
        config.success(successOpts);
        
        return false;
      },

      close: function() {
        config.$input.val('').data().customRecognizeAutoComplete.term = null;
      },
      source: function(request, response) {
        var term = request.term;
        var cachedResults = cachedResultsHash[term];

        if (cachedResults) {
          return callResponse(response, cachedResults, term)
        }
        
        request.limit = 5;
        
        if (this.createUsers && term.indexOf("@") > -1) {
          response([term]);
        } else {
          if (this.createUsers && window.R.y && window.R.y.isLoggedIn && navigator.onLine !== false) {
            window.R.y.autocomplete(request.term, request.limit, function(data) {
              var userArray = [];

              data.user.forEach(function(user) {
                if (user.email) {
                  if (user.email !== currentUserEmail) {
                    userArray.push(user);
                  }
                } else {
                  userArray.push(user);
                }
              });
              
              userArray.push(term);
              callResponse(response, userArray, term)
            }.bind(this), function() {
              getCoworkers(request, response, term);
            });
          } else {
            getCoworkers(request, response, term);
          }

        }
      }
    };
    
    return options;
  };

  function getCoworkers(request, response, term) {
    $.getJSON("/coworkers", request, function(data) {
        var suggestions = [];
        //TODO: if list is greater than X
        //      prompt user to type more letters
        $.each(data, function(i, val) {
          suggestions.push(val);
        });
      
        if (suggestions.length) {
          cachedResultsHash[term] = suggestions;
        }

        suggestions.push(term);

        //response(suggestions);
        callResponse(response, suggestions, term)
      }.bind(this));
  }

  function callResponse(response, suggestions, term) {
    var teams = window.R.teams.filter(function(team){
      if (team.label.toLowerCase().indexOf(term.toLowerCase()) !== -1) {
        return true;
      } else {
        return false;
      }
    });
    suggestions.splice.apply(suggestions, [suggestions.length-1, 0].concat(teams));
    return response(suggestions);
  }
  return A;

})(window);