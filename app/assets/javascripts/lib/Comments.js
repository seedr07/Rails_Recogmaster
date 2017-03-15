window.R = window.R || {};

window.R.Comments = (function($, window, body, R, undefined) {
  var NAMESPACE = "#comments-";
  
  var Comments = function($container) {
    this.addEvents();
  };
    
  Comments.prototype.addEvents = function() {
    $window.bind("ajaxify:success:comment_add", this.add);

    $body.on("keyup", ".comments-wrapper .input-xlarge", function() {
      var $btn = $(this).parent().next();
      if (this.value !== "") {
        $btn.attr("disabled", null);
      } else {
        $btn.attr("disabled", "disabled");
      }
    });

    $document.bind("page:fetch", this.removeEvents.bind(this));
  };

  Comments.prototype.removeEvents = function() {
    $window.unbind("ajaxify:success:comment_add", this.add);
  };

  Comments.prototype.add = function(e, data) {
    var data = data.data.params;
    var wrapperId = NAMESPACE+data.recognition_id;

    $(".no-comments").hide();
    $(wrapperId+" #comment_content").val("");
    $(wrapperId + " .comments-list-wrapper").append( $( data.comment ) );
  };
  
  return Comments;
  
})(jQuery, window, document.body, window.R);