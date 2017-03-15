window.R = window.R || {};
window.R.pages = window.R.pages || {};

window.R.pages["home-index"] = (function($, window, undefined) {
  var player;
  var teamVideoTimer = 0;
  var videoPlayer = null;
  var settingUpVideo = false;
  var timer = 0;

  function createVideo() {
    var tag = document.createElement('script');

    tag.src = "https://www.youtube.com/iframe_api";
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

    // 3. This function creates an <iframe> (and YouTube player)
    //    after the API code downloads.
    window.onYouTubeIframeAPIReady = function() {
      player = new YT.Player('demo-video', {
        height: '100%',
        width: '100%',
        videoId: 'G7OkLzThmYg',
        playerVars: {rel: 0},
        events: {
          'onReady': playVideo
        }
      });
    }
  }

  function prepVideo(e) {
    var height = $window.height() - 12;
    var $video = $("#demo-video");
    $body.addClass("demo-show");
    
    if (!player) {
      createVideo();
    } else {
      playVideo();
    }

    e.preventDefault();
    $video.height(height);
  }

  function playVideo() {
    player.playVideo();
    player.setVolume(30);
  }

  function pauseVideo() {
    player.pauseVideo();
  }

  function closeDemo() {
    $body.removeClass("demo-show");
    pauseVideo();
  }

  /*
  *
  * Constructor
  *
  *
  * */
  var H = function() {
    H.superclass.constructor.apply(this, arguments);
  };

  R.utils.inherits(H, R.pages.home);

  H.prototype.removeEvents = function() {
    $body.off(R.touchEvent, "#scrollUpToForm");
    delete window.onYouTubeIframeAPIReady;
    $window.off();
    settingUpVideo = false;
  };

  return H;
})(jQuery, window);