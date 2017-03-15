(function() {



  // chat widget
  //
  //
  //
  //
  //
  //
  function ChatWidget(initialMessage) {
    this.$chatWrapper = $("#chat-chat");
    this.messageTemplate = Handlebars.compile( jQuery("#chat-chat-thread-template").html() );
    this.$threadWrapper = $("#chat-chat .chat-chat-thread");
    this.askEmailComplete = false;

    this.setDimensions();
    this.showInitialMessage(initialMessage);
    this.events();
  }

  ChatWidget.prototype.respondedEvent = "chatChatUserResponded";

  ChatWidget.prototype.postMessage = function(params) {
    var that = this;

    params.timeout = params.timeout || 0;
    setTimeout(function () {
      var message = window.chatChat.messages.default, html;
      message.body = params.body;
      message.you = params.you;
      html = that.messageTemplate(message);
      that.$threadWrapper.append(html);
      that.scrollToBottom();
      if (params.callback) {
        params.callback();
      }
    }, params.timeout);
  };

  ChatWidget.prototype.setDimensions = function() {
    this.$chatWrapper.find(".chat-chat-thread").css("max-height", $(window).height()/2.3);
  };

  ChatWidget.prototype.showInitialMessage = function(message) {
    message = message || window.chatChat.messages.default.body;

    this.postMessage({
      timeout: 0,
      body: message
    });

    window.recognize.patterns.storage.get("chat_thread_id", function(current_thread_id) {
      if (current_thread_id) {
        $("#chat_thread_id").val(current_thread_id);
      }
    });

    this.$chatWrapper.removeClass("chat-chat-none");

    $("#chat_thread_first_message_field").val(message);
  };

  ChatWidget.prototype.scrollToBottom = function() {
    var chatThreads = this.$chatWrapper.find(".chat-chat-thread")[0];
    chatThreads.scrollTop = chatThreads.scrollHeight;
  };

  ChatWidget.prototype.events = function() {
    var that = this;

    $document.on("click", "#chat-chat .chat-chat-close", function() {
      that.$chatWrapper.removeClass("open");
    });

    $document.on("click", "#chat-chat .chat-chat-thread", function() {
      that.$chatWrapper.addClass("open");
      that.scrollToBottom();
      $document.trigger("chatChat.opened");
    });

    $document.on("ajax:complete", "#chat-chat .chat-chat-form", function(e, data) {
      var chat_thread_id = data.responseJSON.chat_thread_id;
      window.recognize.patterns.storage.set("chat_thread_id", chat_thread_id);
      $("#chat_thread_id").val(chat_thread_id);
    });

    $document.on("ajax:beforeSend", "#chat-chat .chat-chat-form", function(e, settings) {
     that.beforeSend(this, e, settings);
    });
  };

  ChatWidget.prototype.beforeSend = function(el, e, settings) {
    var $textarea = $(el).find("textarea");
    var message = $textarea.val(), html;

    if (message === "") {
      return settings.abort();
    }

    this.postMessage({
      body: message,
      you: true
    });

    $textarea.val("");

    this.sendAutomaticReply(message);

    $document.trigger(this.respondedEvent);
  };

  ChatWidget.prototype.sendAutomaticReply = function(message) {
    var that = this;
    window.recognize.patterns.storage.get("chat_thread_email", function(hasEmailAlreadySet) {
      if (hasEmailAlreadySet !== "true") {
        // TODO: Move messages to data.js
        if (!that.askEmailComplete) {
          that.askEmailComplete = true;

          that.postMessage({
            body: "Ok, what is your email? We'll send you a reply.",
            timeout: 2000
          });

        } else if (message.indexOf("@") > -1) {

          that.postMessage({
            body: "Thanks for getting in touch. We'll reply soon via email.",
            timeout: 2000
          });

          window.recognize.patterns.storage.set("chat_thread_email", true);
        }

      } else {
        if (!that.askEmailComplete) {
          that.askEmailComplete = true;

          that.postMessage({
            body: "Thanks for the message. We'll reply shortly via email.",
            timeout: 2000
          });

        }
      }
    });
  };


  /* PageEvents Class for running dom, scroll, and pageView messaging on a chat widget */
  //
  //
  //
  //
  //
  //
  function PageEvents() {
    this.events = {};
    this.addEvents();
  }

  PageEvents.prototype.init = function() {
    var page = PageEvents.getPage(),
      events, pageBody;

    // For running the optimizely experiment
    if ($(document.body).hasClass("chat-chat-experiment")) {
      page = page || {};
      page.events = page.events || {};
      events = page.events;
    } else {
      page = window.chatChat.messages.default;
      events = null;
    }

    window.recognize.patterns.storage.get("chat_thread_id", function(chatThreadId) {
      if (!chatThreadId && (events && (events.dom.length || events.scroll.length))) {
        this.createContextualEvents(events);
      }

      pageBody = chatThreadId ? window.chatChat.messages.hiagain.body : this.getPageViewEvent(page);

      this.chatChatWidget = new ChatWidget(pageBody);

      $(document).on(this.chatChatWidget.respondedEvent, this.killEvents.bind(this));

    }.bind(this));
  };

  PageEvents.prototype.addEvents = function() {
    // Turbolinks
    $document.on("page:fetch", this.killEvents.bind(this));
    $document.on("chatChat.opened", this.triggerGoal);
  };

  PageEvents.prototype.triggerGoal = function() {
    if (window.optimizely) {window.optimizely.push(["trackEvent", "chatChat"]);}
  };

  PageEvents.prototype.createContextualEvents = function(events) {
    var $document = window.$document || $(document);
    this.events = events;

    if (events.dom && events.dom.length) {
      events.dom.forEach(function(event) {
        this.domEvent(event);
      }.bind(this));
    }

    if (events.scroll && events.scroll.length) {
      this.startScrollEvent();
    }
  };

  PageEvents.prototype.startScrollEvent = function() {
    var timer = 0;
    var windowHeight = $window.height();

    if (this.events.scroll.length === 0) {return;}

    this.events.scroll.forEach(function(event) {
      event.scrollPosition = $(event.element).offset().top;
    });

    $window.bind("scroll.chat-chat", function() {
      clearTimeout(timer);

      timer = setTimeout(function() {
        var windowScrollPosition = $window.scrollTop();

        this.events.scroll.forEach(function(event) {
          if (event.scrollPosition < (windowScrollPosition + windowHeight/3)
            && !(event.scrollPosition+windowHeight < windowScrollPosition)
            && !event.viewed) {

            this.fireEvent(event);
            event.viewed = true;

          }
        }.bind(this));

      }.bind(this), 500);

    }.bind(this));
  };

  PageEvents.prototype.domEvent = function(event) {
    $document.on(event.type+".chatChat", event.element, function() {
      this.fireEvent(event);
    }.bind(this));
  };

  PageEvents.prototype.killEvents = function() {
    var $document = window.$document || $(document);

    if (this.events.dom && this.events.dom.length) {
      this.events.dom.forEach(function (event) {
        $document.off(event.type + ".chatChat", event.element);
      });
    }

    $document.off("page:fetch", this.killEvents.bind(this));
    $document.off("chatChat.opened", this.triggerGoal);
    $window.unbind("scroll.chat-chat");

    // Clear events object and reset loader properties
    this.events = {};
    loader.timer = 0;
    loader.counter = 0;
    loader.optimizelyIsLoaded = false;
  };

  PageEvents.prototype.fireEvent = function(event) {
    var $childrenToRemove;

    // Post the message from the data.js file from an event
    this.chatChatWidget.postMessage({
      body: event.body,
      timeout: event.timeout,
      callback: function() {
        this.chatChatWidget.$chatWrapper.addClass("new");

        setTimeout(function() {
          this.chatChatWidget.$chatWrapper.removeClass("new");
        }.bind(this), 50);
      }.bind(this)
    });

    if (event.type) {
      // Turn off event so doesn't say same thing twice.
      $document.off(event.type+".chatChat", event.element);
    }

    setTimeout(function() {
      try {
        this.chatChatWidget.$chatWrapper.find(".chat-chat-thread .chat-chat-thread-item:not(:last)").remove();
      } catch(e) {}

    }.bind(this), 1000);
  };

  PageEvents.prototype.getPageViewEvent = function(page) {
    page = page || [];
    page.events = page.events || [];
    page.events.pageView = page.events.pageView || [];

    return page.events.pageView.body || window.chatChat.messages.default.body;
  };

  PageEvents.getPage = function() {
    var page;
    var path = window.location.pathname;

    // Remove last slash /
    if (path.length > 1) {
      path = path.replace(/\/$/, '');
    }

    return window.chatChat.messages.pages[ path ];
  };


  window.optimizely = window.optimizely || [];


  // Specific for optimizely loader
  //
  //
  //
  //
  //
  //
  function loader() {
    var page;
    if (loader.counter === 100) {
      return clearTimeout(loader.timer);
    }

    // TODO: Check if optimizely already loaded or not.
    if (window.optimizely && !loader.optimizelyIsLoaded) {
      window.pageChat = new PageEvents();
      page = PageEvents.getPage();

      loader.optimizelyIsLoaded = true;

      if (page) {window.optimizely.push(["activate", page.id]);}
    }

    if ($(document.body).hasClass("chat-chat")) {
      clearTimeout(loader.timer);
      window.pageChat.init();
    } else {
      loader.counter++;
      loader.timer = setTimeout(loader, 500);

      if (!!window.location.href.match("q=true")) {
        $(document.body).addClass("chat-chat-experiment chat-chat");
      }
    }
  }

  loader.timer = 0;
  loader.counter = 0;
  loader.optimizelyIsLoaded = false;

  window.chatChat = window.chatChat || {};
  window.chatChat.loader = loader;
})();