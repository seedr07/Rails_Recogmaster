window.recognize = window.recognize || {};
window.recognize.Post = (function() {

  var Post = function(container) {
    this.container = container;
  };

  Post.prototype.recognitionId = function() {
    var regexp = new RegExp("http.*\/(.*)$");
    return regexp.exec(this.container.find(".yj-title a").prop('href'))[1];
  };

  Post.prototype.authorYammerId = function() {
    return this.container.find('.yj-byline > .yj-hovercard-link').data('resource-id');
  };

  Post.prototype.isPraise = function() {
    return this.container.find(".yj-praise-attachment-comment").length > 0;
  };

  Post.prototype.isRecognition = function() {
    return this.container.find(".yj-img-container [href*='"+window.recognize.host+"']").length > 0;
  };

  Post.prototype.praiseText = function() {
    var str = this.container.find(".yj-praise-attachment-comment").text();
    return jQuery.trim(str.substring(1, str.length-1));
  };

  Post.prototype.recognitionText = function() {
    return jQuery.trim(this.container.find(".yj-attachments-render-container .yj-description").text());
  };
  
  Post.prototype.postText =function() {
    return this.container.find(".yj-message").text();
  };
  
  Post.prototype.get$Approval = function() {
    return this.container.find(".recognize-approval");
  };

  Post.prototype.text = function() {
    if(this.isPraise()) {
      return this.praiseText();

    } else if(this.isRecognition()) {
      return this.recognitionText();

    } else {
      return this.postText();
    }
  };

  return Post;
})();
