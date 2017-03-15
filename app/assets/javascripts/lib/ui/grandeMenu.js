(function() {
  var timer = 0,
    $window = window.$window || $(window),
    $body = window.$body || $(document.body),
    $navs;

  var CLASS_NAME = "its-too-narrow-now";

  // Making sure the menu doesn't go off the page when browser is too narrow
  function conformMenu() {
    var $grandeMenu = $(this),
      $openDropdown,
      position,
      $tooNarrowMenu;

    if (!$grandeMenu || ($openDropdown = $grandeMenu.find(".dropdown-menu")).length === 0) {
      return;
    }

    position =  $openDropdown.offset().left;

    if ( $window.width() > 752 ) {
      var navDropdownIsSeparatedFromButton = Math.round($grandeMenu.offset().left + $grandeMenu.outerWidth()) > Math.round(position + $openDropdown.outerWidth() + 1);

      if ( position <= 10 && !$grandeMenu.hasClass(CLASS_NAME) && !navDropdownIsSeparatedFromButton) {
        $grandeMenu.addClass(CLASS_NAME);
      }

      if (navDropdownIsSeparatedFromButton) {
        $grandeMenu.removeClass(CLASS_NAME);
      }

    } else {
      if ( ($tooNarrowMenu = $(".navbar-nav .grande-menu."+CLASS_NAME)).length ) {
        $tooNarrowMenu.removeClass(CLASS_NAME);
      }
    }

  }

  $navs = $(".navbar-nav .grande-menu");

  if ($navs.length === 0) {
    $(function() {
      $navs = $(".navbar-nav .grande-menu");
      setupShowEvent();
    });
  } else {
    setupShowEvent();
  }

  function setupShowEvent() {
    $navs.on("shown.bs.dropdown", conformMenu);
  }

  $window.resize(function() {
    clearTimeout(timer);
    timer = setTimeout(function() {
      conformMenu.call( $(".grande-menu.open")[0] );
    }, 50);
  });
})();