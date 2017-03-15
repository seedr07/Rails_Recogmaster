//

window.R = window.R || {};

window.R.Uploader = (function($, window, body, R, undefined) {
  var $progress;

  var N = function($container, callback) {
    this.$container = $container;
    this.buttonText = this.$container.find(".button").val();
    this.callback = callback;
    $progress = this.$container.find(".progress-bar");
    this.addEvents();
  };

  N.prototype.addEvents = function() {
    this.attachFileUploadHandler();
  };

  N.prototype.attachFileUploadHandler = function() {
    var that = this;
    this.fileupload = this.$container.fileupload({
      dataType: "json",
      maxNumberOfFiles: 1,
      autoUpload: false,
      /* be wary of replaceFileInput - used to make sure selected file shows - may screw with iFrameTransport */
      /* https://github.com/blueimp/jQuery-File-Upload/wiki/Options#replacefileinput */
      replaceFileInput: false,
      add: function(e, formData) {
        var $submitBtn = that.$container.find("input[type=submit]");
        $submitBtn.unbind();
        $submitBtn.on('click', function(evt){
          evt.preventDefault();
          formData.submit();
        });
      },
      progressall: function (e, data) {
        var progress = parseInt(data.loaded / data.total * 100, 10);
        var $bar = that.$container.find(".progress-inner");

        $bar.css(
          'width', progress + '%'
        );

        if (progress === 100) {
          that.$container.find('.file-attach-progress .message').html("Uploaded Complete. Processing photo...");
          $progress.find("span").text("Uploaded");
        }
      },
      beforeSend: function() {
        var $submitBtn = that.$container.find(".button");
        $submitBtn.attr('disabled', 'disabled');
        $submitBtn.val("Loading...");

        $progress.find("span").text("Uploading");
        $progress.addClass("active");
      },
      fail: function(e, data) {
        that.failedUpload(data);
      },
      done: function(e, data) {
        var json = data.jqXHR.responseJSON;

        if(json.errors) {
          return that.failedUpload(data);
        }

        $progress.removeClass("active");

        that.$container.find(".error").remove();

        if ($(window).width() < 701) {
          R.ui.drawer.close();
        }

        if (that.callback) {
          that.callback(e, json);
        }
      },
      always: function(e, data) {
        var $submitBtn = that.$container.find(".button");
        $submitBtn.val(that.buttonText);
        $submitBtn.attr('disabled', null);

        that.$container.find('.file-attach-progress .message').html("");

      }
    });
  };

  N.prototype.failedUpload = function(data) {
    var errors = data.jqXHR.responseJSON.errors;
    var formErrors = new window.R.forms.Errors(this.$container, errors, data.jqXHR.responseJSON);

    formErrors.renderErrors();
  };

  N.prototype.submit = function() {};

  N.prototype.reset = function() {};

  N.prototype.openCrop = function() {};

  N.prototype.closeCrop = function() {};

  return N;

})(jQuery, window, document.body, window.R);