window.R.init = function() {
  var hasTouch;
  var dataScript = document.body.getAttribute("id");
  var mixPanelTimer = 0;
  var $notice =  $("#notice");
  R.nameSpace();

  var r = window.R || {};

  r.priceMap = {
    0: [49, 199],
    100: [79, 299],
    500: [159, 599],
    1000: [299, 899],
    5000: [599, 1499],
    10000: [999, 2999]
  };

  window.R.utils.browserDetector();

  hasTouch = Modernizr.touch;
  r.touchEvent = (hasTouch) ? "tap" : "click";

  requiredToStart();

  if (r.pages[dataScript] && !window.R.currentPage) {
    window.R.currentPage = new r.pages[dataScript]();
  }

  R.transition = new R.Transition();

  if (!hasTouch) {
    if ($.fn.tooltip) {
      $("[title]").tooltip({
        placement: "bottom",
        delay: 500
      });
    }
  } else {
    $html.addClass("touch");
  }
  
  $(window).load(function() {
    $body.addClass("ready");
  });

  $document.on(R.touchEvent, ".animate-scroll", function() {
    var $el = $(this), href, offset;

    if ($el.data("href")) {
      href =  $el.data("href");
    } else {
      href =  $el.attr("href");
      $el.data("href", href);
    }

    offset = $(href).offset().top;

    $("html, body").animate({
      scrollTop: (offset - 90) +"px"
    });
  });

  $('input, textarea').placeholder();

  function removeEventsFromCurrentPage() {
    if (R.currentPage && R.currentPage.removeEvents) {
      R.currentPage.removeEvents();
    }
  }

  function requiredToStart() {
    if (!R.isTurbo) {

      $document
      .bind("page:fetch", function() {
        R.isTurbo = true;
        $html.addClass("loading");
        removeEventsFromCurrentPage();
        R.ui.header.removeEvents();
        window.R.ui.drawer.close();
        $document.off("recognize:init")
      })
      .bind("page:restore", function() {
        R.init();
      })
      .bind("page:receive", function() {
        $html.removeClass("loading");

        if ($.fn.balanceText) {
          setTimeout(function() {
            $(".balance-text").balanceText();
          }, 500);
        }
      });

    }
    
    if ( R.pages && R.pages[dataScript] ) {
      R.currentPage = new R.pages[dataScript]();
    }
    setTimeout(function() {
      $body.addClass("ready");
    }, 1000);

  }
  
  if (!window.R.ui.header) {
    R.ui.header = new R.ui.Header(); 
  } else {
    R.ui.header.addEvents(); 
  }

  if (!window.R.ajaxify) {
    window.R.ajaxify = new window.R.Ajaxify();
  }

  if (window.sweetAlertInitialize && $(".sweet-alert").length == 0) {
    window.sweetAlertInitialize();    
  }
};