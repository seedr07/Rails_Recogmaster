(function() {
  var Page;
  window.R = window.R || {};
  window.R.pages = window.R.pages || {};

  Page = window.R.pages["users-edit"] = function() {
    // if (!$html.hasClass("ie9")) {
    //   $("form.edit_user").data("remote", true);
    // }
    if ($html.hasClass("ie9")) {
      $("form.edit_user").removeAttr("remote");
    }

    this.$progress = $('#progress-bar');

    this.addEvents();
  };

  Page.prototype.removeEvents = function() {
    $("#user_email_setting_attributes_global_unsubscribe").off("change");
    $("#user_avatar").off().unbind();
    $document.off(R.touchEvent, "#cancel-account input[type=submit]");
  };

  Page.prototype.addEvents = function() {
    var that = this;
    $window.on("ajaxify:errors", function() {
      $body.animate({
        scrollTop: 0
      });
    });

    $("#user_email_setting_attributes_global_unsubscribe").on("change", function(){
      var $unsubscribe = $(this);
      if($unsubscribe.is(':checked')) {
        $(".email-settings div.controls:not(.unsubscribe-wrapper) input").addClass("disabled").prop("disabled", "disabled");
        $(".email-settings div.controls:not(.unsubscribe-wrapper) label").addClass("subtle-text")
      } else {
        $(".email-settings div.controls:not(.unsubscribe-wrapper) input").removeClass("disabled").removeAttr("disabled");
        $(".email-settings div.controls:not(.unsubscribe-wrapper) label").removeClass("subtle-text")
      }
    });


    // IE9 doesn't support file ajax for setting custom response headers.
    // Thus we turn off ajax for IE and no ajax file upload
    if (!$html.hasClass("ie9")) {
      $("#user_avatar").fileupload({
        dataType: "script",
        progressall: function (e, data) {
          var progress = parseInt(data.loaded / data.total * 100, 10);
          var $bar = $("#progress-inner");

          $bar.css(
            'width', progress + '%'
          );

          if (progress === 100) {
            $('#avatar-control .file-attach-progress .message').html("Uploaded Complete. Processing photo...");
            that.$progress.find("span").text("Uploaded");
          }
        },
        beforeSend: function(xhr) {
          that.$progress.find("span").text("Uploading");
          that.$progress.addClass("active");
        },
        done: function() {
          that.$progress.removeClass("active");
        }
      });
    }

    $document.on(R.touchEvent, "#cancel-account input[type=submit]", function(){
      swal({
          title: "Are you sure?",
          text: "This will cancel your account and log you out.",
          type: "warning",
          showCancelButton: true,
          confirmButtonColor: "#DD6B55",
          confirmButtonText: "Yes, cancel it!",
          closeOnConfirm: false },
        function(){
          $("#cancel-account").submit();
        });
      return false;
    });
  };

})();

