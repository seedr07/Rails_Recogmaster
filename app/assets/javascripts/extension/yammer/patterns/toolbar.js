(function() {
  window.recognize = window.recognize || {};
  window.recognize.patterns = window.recognize.patterns || {};
  window.recognize.patterns.toolbar = {
    create: create
  };

  var $toolbar,
      templateSidebar,
      templateTopbar,
      languageSet;

  window.$body = window.$body || jQuery(document.body);

  function create(isLoggedIn, callback) {
    languageSet = window.recognize.patterns.i18n();


    if (!templateSidebar || !templateTopbar) {
      recognize.ajax({
        url: recognize.file.getPath("templates/toolbar.html"),
        success: function(html) {

          $body.append( html );

          templateTopbar = Handlebars.compile( jQuery("#r-recognitions-toolbar").html() );
          templateNewMain = Handlebars.compile( jQuery("#r-recognitions-toolbar-new-main").html() );

          attachToolbar(isLoggedIn);
        }.bind(this)
      });
    } else {
      attachToolbar(isLoggedIn);
    }

    function attachToolbar(isLoggedIn) {
      var template;
      var $mainColumnToolbar = jQuery("#column-two").find(".yj-global-publisher-switcher");
      var $sideColumnToolbar = jQuery("#column-one").find(".yj-nav-menu--primary-actions");

      if (jQuery("#column-one .yj-nav-menu--fixed-content").length > 0) {
        template = templateNewMain;
        $toolbar = $mainColumnToolbar;
      } else {
        $toolbar = jQuery(".yj-header-navigation--jewels-left").first();
        template = templateTopbar;
      }

      if (window.recognize.currentUser && window.recognize.currentUser.company_admin === "false") {
        window.recognize.currentUser.company_admin = false;
      }

      if (jQuery("#recognize-list").length > 0) {
        jQuery("#recognize-list").remove();
      }

      $toolbar.append(template({
        user: window.recognize.currentUser,
        loggedIn: isLoggedIn,
        signupUrl: window.recognize.host+'/auth/yammer',
        i18n: languageSet
      }));

      if ($sideColumnToolbar.length > 0 && jQuery("#recognize-list-sidebar").length === 0) {

        template = Handlebars.compile( jQuery("#r-recognitions-toolbar-sidebar").html() );

        $sideColumnToolbar.append(template({
          user: window.recognize.currentUser,
          loggedIn: isLoggedIn,
          signupUrl: window.recognize.host+'/auth/yammer',
          i18n: languageSet
        }));
      }

    }

    window.$body.on("click", "#recognize-someone-trigger", function(e) {
      e.preventDefault();
      recognize.patterns.recognitionForm.open();
    });

    window.$body.on("click", "#company-admin-trigger", function(e) {
      e.preventDefault();
      openIframe(languageSet.company_admin, window.recognize.path("company"));
    });

    window.$body.on("click", "#reports-trigger", function(e) {
      e.preventDefault();
      openIframe(languageSet.stats, window.recognize.path("reports"));
    });
  }

  function openIframe(title, url) {
    var iframeHTML, gettingModalUrl, template;

    template = Handlebars.compile(jQuery('#r-iframe').html());

    iframeHTML = template({
      url: url,
      id: 'r-stats-iframe',
      height: $(window).height() - 100+"px"
    });

    recognize.patterns.overlay.open(title, iframeHTML, "full");
  }

})();