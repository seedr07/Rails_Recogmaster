(function() {
  var pageID,
      slaveObject = {},
      xdomain = window.recognize.xdomain,
      praiseTimer = 0,
      praiseCounter = 0,
      isLoading = false;

  window.recognize = window.recognize || {};

  //window.recognize.host = !window.localStorage && !localStorage["recognize-hostname"] ? "//recognizeapp.com" : localStorage["recognize-hostname"];
  window.recognize.host = "//recognizeapp.com";

  window.recognize.removePraise = function() {
    var $praise = jQuery("[data-name='praisePublisher']");
    clearTimeout(praiseTimer);
    if ($praise.length === 0 && praiseCounter < 100) {
      praiseCounter++;
      praiseTimer = setTimeout(function() {
        window.recognize.removePraise();
      }, 500);
    } else {
      try {
        $praise.remove();
      } catch(e) {}

    }
  };

  if (xdomain) {
    slaveObject["https:"+window.recognize.host] = "/proxy.html";
    xdomain.slaves(slaveObject);
  }

  function auth(currentYammerUsername) {
    var pingingAuthentication;

    if (isLoading === true) {
      return;
    }

    isLoading = true;

    pingingAuthentication = window.recognize.patterns.api.get('/ping', {username: currentYammerUsername});

    pingingAuthentication.done(function(data) {
      var CurrentPage;
      var el1 = jQuery("<div>");
      var feed;

      if (data.status !== 'false' && data.yammer !== 'false') {
        window.recognize.yammerID = data.yammer_id;
      } else {
        return window.recognize.patterns.api.unauthenticated(data);
      }

      if (jQuery(".yj-user-profile--header").length) {
        window.recognize.currentPage = new window.recognize.pages["users-show"];
      }

      recognize.patterns.overlay.init();

      window.recognize.removePraise();

      window.recognize.currentUser = data;

      feed = new window.recognize.patterns.Feed();

      el1.load( window.recognize.file.getPath("templates/overlay.html") );

      $body.append(el1);

      recognize.patterns.toolbar.create(true);

      isLoading = false;

    }.bind(this));
  }

  window.recognize.init = function() {
    var stylesheet,
        href = window.location.href,
        $profile;

    window.recognize.removePraise();

    if (!href.match(/yammer.com/) && href.match(/recognizeapp.com/)) {
      jQuery("#notice.yammer").remove();
    } else {

      window.recognize = window.recognize || {};
      window.recognize.patterns.api = new window.recognize.patterns.Api();

      window.$body = window.$body || jQuery('body');

      stylesheet = document.createElement("link");
      stylesheet.setAttribute("href", window.recognize.host + "/assets/extension.css");
      stylesheet.setAttribute("rel", "stylesheet");
      stylesheet.setAttribute("type", "text/css");
      $body.append(stylesheet);

      window.recognize.file = new window.recognize.patterns.File();

      pageID = $body.attr('id');
      window.recognize.pageID = pageID;

      if (window.yam && window.yam.api && window.yam.api.getCurrentUser) {

        window.yam.api.getCurrentUser().done(function(user) {
          if (user.id) {
            auth(user.id);
          }
        });

      } else {
        $profile = jQuery(".yj-nav-user .yj-nav-user-name");

        if ($profile.length === 0) {
          $profile = jQuery(".yj-nav-menu--user-name");

          if ($profile.length === 0) {
            return;
          }
        }

        auth( $profile.prop('href').match(/users\/(.*)$/)[1] );
      }

    }
  };

  window.recognize.path = function(path) {
    return window.recognize.host+"/"+window.recognize.currentUser.network+"/"+path;
  };

  loadDepedencies();

  jQuery(document).off("click.recognize", "#column-one a");

  jQuery(document).on("click.recognize", "#column-one a, .yj-feed-choices li, .yj-lightbox-content a", function() {
    reload();
  });

  function loadDepedencies() {
    var script;

    if (!window.Handlebars) {
      script = document.createElement("script");

      document.body.appendChild(script);

      jQuery(script).load(function() {
        initRecognize();
      });
      script.setAttribute("type", "text/javascript");
      script.setAttribute("src", "//cdnjs.cloudflare.com/ajax/libs/handlebars.js/1.3.0/handlebars.min.js");

    } else {
      initRecognize();
    }
  }

  function initRecognize() {
    setTimeout(function() {
      window.recognize.init();
      watchDom(true);
    }, 1500);
  }

  function watchDom(run) {
    var observer, config;

    // select the target node
    var target = document.querySelector('#column-two');

    if (!target || !window.MutationObserver) {
      return;
    }

    // create an observer instance
    observer = new MutationObserver(function(mutations) {
      reload();
    });

    // configuration of the observer:
    config = { attributes: true, childList: true, characterData: false };

    // pass in the target node, as well as the observer options
    observer.observe(target, config);
  }

  function reload() {
    isLoading = false;

    if (jQuery(this).closest("#recognize-list-sidebar").length > 0) {
      return;
    }

    setTimeout(function() {
      if (jQuery("#recognize-list").length === 0) {
        window.recognize.init();
      }
    }, 1000);
  }

  window.recognize.removePraise();
})();