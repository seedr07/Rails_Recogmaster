// Some notes on the way I implemented this
// At first, I implemented the request right here in this file via ajax
// however, i had trouble getting the success function to fire
// so I followed the way Comments.js works, and that runs through Ajaxify
// and so to do that, we wrap the person div in a link tag with remote: true
// this has the benefit of lightening up the javascript quite a bit as well as the fact 
// that we don't need to hard code urls in js anymore(its handled by the link_to rails call in the view)
window.R = window.R || {};

window.R.instantRecognition = (function(window, body, R, undefined) {

  var IR = function($container) {
    if ($("html").hasClass("fullscreen")) {return;}

    if (window.yammerSettings && window.yammerSettings.accessToken) {
      this.addEvents();
      this.getRelevantYammerCoworkers();
    }
  };
    
  IR.prototype.addEvents = function() {
    $window.bind("ajaxify:beforeSend", this.beforeSend);
    $window.bind("ajaxify:success:recognition_create", this.successfullyRecognized);
    $document.bind("page:fetch", this.removeEvents.bind(this));
  };

  IR.prototype.removeEvents = function() {
    $window.unbind("ajaxify:beforeSend", this.beforeSend);
    $window.unbind("ajaxify:success:recognition_create", this.successfullyRecognized);
    $document.unbind("page:fetch", this.removeEvents.bind(this));
  };

  IR.prototype.beforeSend = function(evt) {
    var $person = $(evt.target).find(".person");
    $person.addClass("recognized");
    $person.find(".recognized-status").html("Recognized").removeClass("reset");
  };

  IR.prototype.getRelevantYammerCoworkers = function(success) {
    $.ajax({
        url: '/'+document.body.getAttribute("data-name")+'/get_relevant_yammer_coworkers',
        type: "GET",
        success: function(data){
          document.getElementById("people-wrapper").innerHTML = data;

           $("#instantRecognition-wrapper").fadeIn();

          this.handleMissingYammerAvatars();
        }.bind(this)
    });    
  };  

  IR.prototype.successfullyRecognized = function(e, response) {
    var responseData = response.data.params;
    
    if(responseData.yammer_id) {
      var $person = $(".person[data-yammerid="+responseData.yammer_id+"]")
    } else {
      var $person = $("#person_"+responseData.person_id+" .person");
    }

    var $showRecognitionLink = $("<a>");
    $showRecognitionLink.prop('href',  responseData.recognition_url);
    $showRecognitionLink.html("Recognized");

    $person.find(".recognized-status").html($showRecognitionLink);
    $person.unwrap();//remove the surrounding <a> tag so you cant recognize again on this page load

  };

  IR.prototype.handleError = function(e, elementId, errors) {
    var errString = "";

    for (var element in errors) {   
      if (errors[element].constructor === Array) {          
        errors[element].forEach(function(error) {
          errString += error+".  "
        });
      } else {
          errString += error+".  "
      }

    }
    console.log("handling error: ", errString)
  };

  function setAvatars(that) {
    $("#people-wrapper .person").each(function(i, person){
      var $this = $(this);
      if($this.data('yammerid') && $this.find(".avatar-wrapper img").prop('alt') === 'User-default') {
        that.getAvatar($this);
      }
    });
  }

  IR.prototype.handleMissingYammerAvatars = function() {
    var that = this;
    if (!window.R.y || window.yam && !window.yam.request) {
      window.R.y = new window.Yammer(function() {
        setAvatars(that);
      });
    } else {
      setAvatars(that);
    }
  };

  IR.prototype.getAvatar = function($person) {
    var yammerid = $person.data("yammerid");

    yam.request({
      url: "https://www.yammer.com/api/v1/users/"+yammerid+".json", 
      method: "GET",
      success: function (user) { //print message response information to the console
        console.log("success avatar: ", $person)

        var avatar = user.mugshot_url_template.replace('{width}', '110').replace('{height}', '110');
        $person.find(".avatar-wrapper img").prop('src',  avatar);
      },
      error: function (user) {
        console.log("There was an error with the request.");
      }
    });

  };
  return IR;
  
})(window, document.body, window.R);