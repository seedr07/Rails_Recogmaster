window.R = window.R || {};
window.R.ui = window.R.ui || {};

window.R.ui.Post = (function() {
  var $badgeList, $badgeListBest;
  var $newPost;

  var Post = function(type, options) {
    var options = options || {};

    this.createUsers = options.createUsers || true;
    this.type = type || "recognition";
    this.transition = R.transition;

    this.badges = new window.R.ui.BadgeList(this.type);
    this.$recipient_name = $("#"+this.type+"_recipient_name");
    this.$form = $("#new_"+this.type);
    this.$recipients = $("."+this.type+"_recipients");
    this.$message = $("#"+this.type+"_message");

    this.addEvents();
    this.initAutoComplete();

    if (R.recipient) {
      this.addRecepient( R.recipient );
    }

    if ($html.hasClass("ie8") || $html.hasClass("ie9")) {
      var inputValue = this.$recipient_name.attr('placeholder');
      this.$recipient_name.attr("placeholder", "").attr("value", "");
      this.$recipient_name.before($("<label>"+inputValue+"</label>"));
    }

    $("#badge-list [title]").tooltip({
      placement: "bottom",
      delay: 100
    });

    setTimeout(function() {
      this.addYammerWallToggle();
    }.bind(this), 100);
  };

  Post.prototype.addEvents = function() {
    $newPost = this.$form;
    var timer = 0;
    var that = this;

    this.$partialFormWrapper = $("#"+this.type+"-form-wrapper");
    this.$recepient = $("#chosen-recepient-wrapper");

    $document.on(R.touchEvent, "."+this.type+"-overlay-close", this.closeOverlays);

    $window.keyup(function(e) {
      if ( e.keyCode === 27 && ( $("#recognize-badge-list-wrapper.current").length || $("#recognize-reward-wrapper.current").length ) ) {
        R.transition.fadeTop();
      }
    }.bind(this));

    $window.resize(function() {
      clearTimeout(timer);
      timer = setTimeout(function() {
        hasLoadedIsotope = false;
      }, 500);
    });

    $document.on(R.touchEvent, ".button-yammer-signup", this.setFormAttrsOnYammerBtn);

    $newPost.submit(function(e) {
      e.preventDefault();
      this.beforeSend();
    }.bind(this));

    $newPost.bind("ajax:beforeSend", function(e, xhr, settings){
      var params = R.utils.paramStringToObject(settings.data)
      params[this.type+"[recipients][]"]
    });
    $newPost.bind("ajax:success", this.send.bind(this));

    $window.bind("ajaxify:errors", function() {
      $("#recognition-new-wrapper #top").scrollTop(0);
    }.bind(this));

    $document.on(R.touchEvent, ".recipient-remove", this.removeRecepient.bind(this));
  };

  Post.prototype.removeEvents = function() {
    $document.off(R.touchEvent, ".recepient-remove");
    if (this.autocomplete) {delete this.autocomplete;}
    $window.unbind("keyup");
    if ($newPost) {
      $newPost.unbind("ajax:beforeSend");
      $newPost.unbind("ajax:success");
    }
  };

  Post.prototype.closeOverlays = function() {
    R.transition.fadeTop("#recognition-new-wrapper");
  };

  Post.prototype.setFormAttrsOnYammerBtn = function(evt) {
    var $yammerBtn = $(".button-yammer-signup");
    var recognition = {
      badge_id: $("#"+this.type+"_badge_id").val(),
      recipient_email: this.$recipient_name.val(),
      message: this.$message.val()
    };
    var href = $yammerBtn.attr('href').split("?")[0];
    href = href+"?"+$.param({recognition : recognition}, false);
    $yammerBtn.attr('href', href);
  };

  Post.prototype.beforeSend = function(e) {
    $(".message-info").remove();

    this.removeErrors();
  };

  Post.prototype.addRecepient = function(userData) {
    if ( $("[data-signature='"+userData.email+"']").length ) {
      return;
    }
    var html = Handlebars.compile( $("#addRecepient").html() )(userData); // Compile returns a function and then we pass in the data to that.

    $body.focus();

    this.$recepient.removeClass("no-recipients").find(".inner").append(html);

    $("#main-text .hidden-field").val("");

    // the idea here is that we start on page load with
    // one hidden recipient field.  The first recipient is added by user
    // and that data is populated into that first hidden field
    // for, all subsequent recipients we need to add more hidden fields
    // The reason for this is when no recipients are added it gives me a field
    // to add errors on to while keeping the error field consistent with the field
    // that is actually passed on form submit
    if(this.$recipients.length === 1 && this.$recipients.val() === "") {
      var $hidden_recipient_field  = this.$recipients.first();
    } else {
      var index = this.$recipients.last().data('index')+1;
      var $hidden_recipient_field = $("<input>");
      $hidden_recipient_field.prop({
        type : 'hidden',
        id : this.type+'_recipients_'+index,
        'class' : this.type+'_recipients',
        name : this.type+'[recipients][]'})

      $hidden_recipient_field.data('index', index)
    }

    if ( userData.web_url || userData.email ) {
      $hidden_recipient_field.val(userData.email);
    } else {
      $hidden_recipient_field.val(userData.type+":"+userData.id);
    }

    this.$form.append($hidden_recipient_field);

    setTimeout(function() {
      this.$recipient_name.focus();
    }.bind(this), 100);
  };

  Post.prototype.removeRecepient = function(evt) {
    var $target = $(evt.target).closest('.recipient-wrapper');
    var objSignature = $target.data('signature');

    $target.remove();
    $("."+this.type+"_recipients[value='"+objSignature+"']").remove();

  };

  Post.prototype.initAutoComplete = function() {
    if (window.Autocomplete) {
      this.autocomplete = new window.Autocomplete({
        input: "#"+this.type+"_recipient_name",
        success: this.addRecepient.bind(this),
        createUsers: this.createUsers
      });
    }
  };

  // Todo make yammer work better
  Post.prototype.send = function(e, data) {
    var $chosenBadge,
      senderName,
      badgeName,
      title,
      badgeImagePath,
      recognitionURL;

    if (data.type === "error") {
      return;
    }

    $chosenBadge = $(".button-dark");
    senderName = $("#sender_name").val();
    badgeName = ( $chosenBadge.text() ).replace(/(\r\n|\n|\r|" ")/gm, "").trim();
    title = $("#recognition_recipient_name").val() + " received the " + badgeName + " badge from "+ senderName + '.';
    recognitionURL = data.permalink;

    badgeImagePath = $chosenBadge.siblings(".badge-image-small").data("imagepath");

    if ($("#yammer-toggle").prop("checked")) {
      R.y.postMessage({
        title: title,
        image: badgeImagePath,
        url: recognitionURL,
        message: this.$message.val()
      });
    }

    if(data.flash) {
      this.cleanup(data.flash.notice);
    }
  };

  Post.prototype.cleanup = function(message) {
    // reset the button
    $(".button-primary").removeClass("button-primary").find(".icon-ok").addClass("opacity0");
    // clear form fields
    $("input[type=text], textarea").val("");

    // display the message
    $("#recognition-form-wrapper").prepend("<div class=message-info><h4>"+message+"</h4></div>");

    // hide error messages
    this.removeErrors();
  };

  Post.prototype.removeErrors = function() {
    $(".recognition-send-error-wrapper").children().remove();
  };

  Post.prototype.addYammerWallToggle = function() {
    var $input = $("#recognition-new-wrapper .on-off");

    $input.iOSCheckbox({
      onChange: function() {
        // var $target = $(this.elem), data = {};
        // var checkedValue = this.elem.prop("checked") ? true : false;
        // data[$target.data('setting')] = checkedValue;

      }
    });

  }
  return Post;
})();

["recognitions-edit", "recognitions-create", "recognitions-new_chromeless", "recognitions-new"].forEach(function(page) {
  window.R.pages[page] = function() {
    return new window.R.ui.Post("recognition");
  }
});