(function() {
  window.R = window.R || {};
  window.R.ui = window.R.ui || {};
  window.R.ui.drawer = {
    open: open,
    close: close
  }

  var isOpen = false;

  function close() {
    $html.removeClass("drawer-open");
    $(".drawer-trigger.button").removeClass("button-pressed");
    $document.trigger("drawer-close");
    isOpen = false;
  }

  function open() {
    var $wrapper  = $("#view-drawer-wrapper");
    var $formFields = $wrapper.find("input, select, textarea").not("input[type='submit'], .button");
    $formFields.attr("disabled", "disabled");
    $(".drawer-trigger.button").addClass("button-pressed");
    $html.addClass("drawer-open");
    isOpen = true;
    setTimeout(function() {
      $formFields.removeAttr("disabled");
    }, 310);

    if ($("body").hasClass("header-menu-open")) {
      $(".header-menu-trigger").click();
    }

    setHeight($wrapper);

    if (R.ui.header) {
      R.ui.header.closeMenu();
    }
  }

  function setHeight($wrapper) {
    $wrapper.find(".inner").height($wrapper[0].scrollHeight + 50);
  }

  $document.on(R.touchEvent, ".drawer-trigger", function() {
    if ( $(".drawer-open").length === 0 ) {
      open();
    } else {
      close();
    }
  });


})();


