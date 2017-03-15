(function() {

  var cards = [];

  var tabToContentMap = {
    "#sent": '#profile-recognitions-sent',
    "#received": '#profile-recognitions-received',
    "#achievements-tag": "#recognitions-achievements"
  };

  window.R = window.R || {};
  window.R.pages = window.R.pages || {};

  window.R.pages["users-show"] = function() {
    this.pagelet = new window.R.Pagelet();

    var resizeTimer;
    var child = '.recognition-card';

    this.addEvents();

    loadCards("#received");
  };

  window.R.pages["users-show"].prototype = {
    addEvents: function() {
      $('a[data-toggle="tab"]').on("shown", function (e) {
        var href = e.target.getAttribute("href");
        var el;

        try {
          el = tabToContentMap[ href ];
        } catch(e) {
          return;
        }

        loadCards(el);

        if (href !== "#nametag-tab") {
          $("#nametag-tab").removeClass("active");
        } else {
          $(".tab.active").removeClass("active");
          $("#nametag-tab").addClass("active");
        }
      });

    },
    removeEvents: function() {
      $('a[data-toggle="tab"]').off('shown');
      $("#user_slug").off("keyup");
    }
  };


  function loadCards(el) {
    var $el = $(el);

    if ($el.find(".recognition-card").length > 0 && $el.data("loaded") !== true) {

      cards.push(new R.Cards($el));
      $el.data("loaded", true);

    } else {

      $el.bind("pageletLoaded", function () {
        if ($el.find(".recognition-card").length > 0) {

          cards.push(new R.Cards($el));
          $el.data("loaded", true);
        }
      });

    }

    if ($el.data("loaded")) {
      $el.isotope("reLayout");
    }
  }

})();
