(function() {
  var tourData;
  window.recognize = window.recognize || {};
  window.recognize.tour = tour;

  function tour(metadata) {
    var tourId = metadata.id;
    var that = this;
    var tourData = {
      index: {
        id: "yammer_index_tour",
        steps: [
          {
            target: "#recognize-toolbar",
            placement: "bottom",
            title: "Recognize central",
            content: "Send recognition, see the leaderboards, and browser recognize from here."
          },
          {
            target: jQuery(".r-recognize-trigger")[0],
            placement: "bottom",
            title: "Recognize someone for the post",
            content: "This person is automatically recognized for their post. Edit the recognition afterwards."
          },
        ],
        onEnd: function() {finished("index"); }
      },

      usershow: {
        id: "yammer_usershow_tour",
        steps: [
          {
            target: "#recognition-tab-trigger",
            placement: "bottom",
            title: "Recognitions on user profile",
            content: "Never leave Yammer for your employee recognition."
          },
          {
            target: "#user-recognize-trigger",
            placement: "bottom",
            title: "Easily recognize someone from their profile",
            content: "The Recognize modal is shown with this person automatically selected."
          },
        ],
        onEnd: function() {finished("usershow");}
      }
     
    };
    recognize.patterns.storage.get(tourId, function(response) {

      if (response !== "true") {
        jQuery(".main-header").before('<div id=recognize-oauth-message style="background: #C5EAFF;"><div class=recognize-inner style="max-width: 500px; margin: auto; padding: 20px;"><h2>'+metadata.title+'</h2><button id="recognize-tour-trigger" class="yj-btn yj-btn-alt  "><span>'+metadata.button+'</span></button><a href="javascript://" id="recognize-end-tour" style="margin-left: 10px">'+metadata.cancel+'</a>');
        jQuery("#recognize-end-tour").click(function(e){ finished(metadata.page); });
        jQuery("#recognize-tour-trigger").click(function(e) {
          e.preventDefault();
          hopscotch.startTour(tourData[metadata.page]);
        });
      }
    });
  };

  function finished(page) {
    recognize.patterns.storage.set("recognize-tour-"+page, "true");
    jQuery("#recognize-oauth-message").fadeOut();
  };


})();