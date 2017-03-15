window.R = window.R || {};
window.R.pages = window.R.pages || {};

window.R.pages["recognitions-show"] = (function() {
  
  var Show = function() {
    var timer = 0;
    var $recognitionSignup = $("#recognition-show-signup");
    
    $body.on("click", "#recognition-access-wrapper.access-enabled", togglePrivacy); 
    $body.on("click", "#sharing.access-enabled a", makePagePublic);
    
    (function changeYammerText() {
      var $el = $(".yj-publisher-watermark");
      if ($el.length) {
        $el.text("Leave a comment");
        return clearTimeout(timer);
      }
      timer = setTimeout(changeYammerText, 50);
    })();
    
    if ( $recognitionSignup.length > 0 ) {
      $recognitionSignup.find(".close-icon").click(function(e) {
        e.preventDefault();
        $recognitionSignup.addClass("closed");
      });
    }

    this.comments = new R.Comments();

  };
  
  function makePagePublic() {
    setAccess(true);
  }
  
  function togglePrivacy() {
    setAccess();
  }

  function setAccess(makePublic) {
    var $accessWrapper = $("#recognition-access-wrapper");
    var network = $body.data("name");

    var ajaxMetaData = {
      url: "/"+network+"/recognitions/"+$accessWrapper.data('param')+"/toggle_privacy",
      type: "PUT",
      beforeSend: function(xhr, settings){
        xhr.setRequestHeader('accept', '*/*;q=0.5, ' + settings.accepts.script);
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
      }          
    };
    
    if (makePublic) {
      $accessWrapper.removeClass("private");
      ajaxMetaData.data = {make_public: makePublic}
    } else {
      $accessWrapper.toggleClass("private");      
      if($accessWrapper.data('restrictpublic') === true) {
        $accessWrapper.removeClass("access-enabled")
        $("#sharing").hide();
      }
    }
        
    $.ajax(ajaxMetaData);
  }

  return Show;

})();