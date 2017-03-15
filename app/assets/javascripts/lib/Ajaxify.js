window.R.Ajaxify = (function($window) {
  var SuccessActionsFactory;
  var ajaxForms = [];
  var selectors;
  
  var CSRF_TOKEN = $('meta[name="csrf-token"]').attr('content');
  
  var Ajaxify = function() {
    var selector;
    try {
      selector = $.rails.formSubmitSelector+", "+$.rails.linkClickSelector;
    }catch(err){
      selector = "form[data-remote=true], a[data-confirm], a[data-method], a[data-remote], a[data-disable-with]";
    }

    this.selector = selector;
    this.$selector = $(selector);
    
    this.addEvents();
  };

  $window = $window || $(window);

  Ajaxify.prototype.setupButtons = function(targetElement) {
    var $button,
        $selector = $(targetElement),
        buttonType = $selector[0].tagName,
        buttonConditional,
        selectorHasButton = $selector.hasClass("button");
  
    if (!selectorHasButton && buttonType === "A") {
      return;
    }
    
    if (selectorHasButton && buttonType === "A") {
      $button = $selector;      
    } else {
      $button = $selector.find("[type=submit]");
      if (!$button.length) {return;}
      buttonType = $button[0].tagName;
    }
    buttonConditional = ( ( buttonType.toLowerCase() === "button" || $button.hasClass("button") ) && buttonType.toLowerCase() !== "input" );
    
    if ($button.length) {
      this.button = {
        type: buttonConditional ? "button" : "input",
        $el: $button,
        text: buttonConditional ? $button.text() : $button.val()
      }
    } else {
      this.button = null;
    }
  };
  
  Ajaxify.prototype.addEvents = function() {
    //TODO: make sure $.rails is loaded, perhaps this needs to be specified in app.js
    //Basically, I've noticed in testing that this file is loaded, but $.rails is null
    //and I get an error and it causes all sorts of hell to break loose
    var selector = this.selector,
        $selector = this.$selector;
    
    $document
    .on("ajax:beforeSend", this.selector, this.beforeSend.bind(this))
    .on("ajax:success", this.selector, this.success.bind(this))
    .on("ajax:complete", this.selector, this.complete.bind(this))
    .on("ajax:error", this.selector, this.error.bind(this))
    .on("ajax:send", this.selector, this.send.bind(this))
  };

  Ajaxify.prototype.removeEvents = function() {
    $document
    .off("ajax:beforeSend", this.selector)
    .off("ajax:success", this.selector)
    .off("ajax:complete", this.selector)
    .off("ajax:error", this.selector)
    .off("ajax:send", this.selector)
    .off("ajax:beforeSend", this.selector);    
  };
  
  Ajaxify.prototype.send = function() {
    $window.trigger("analytics", [this.$selector, "sent"]);    
  };
  
  Ajaxify.prototype.beforeSend = function(e, xhr, settings) {
    var $target = $(e.target), uuid;

    //attach uuid to form if not present
    if(!$target.data('formuuid')) {
      uuid = window.R.utils.guid()
      $target.attr('data-formuuid', uuid);
    } else {
      uuid = $target.data('formuuid');
    }


    xhr.setRequestHeader('X-Form-UUID', uuid);
    xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
    $target.trigger("ajaxify:beforeSend");
  };
  
  Ajaxify.prototype.success = function(e, data, status, xhr) {
    this.sucessActionFactory = new SuccessActionsFactory(e, data);
  };
  
  Ajaxify.prototype.setButtonText = function(text) {
    if (!this.button)
      return; 
    
    if (!text) {
      text = this.button.text;
    }
    if (this.button.type.toLowerCase() === "button") {
      this.button.$el.text(text);
    } else {
      this.button.$el.val(text);
    }
  };

  Ajaxify.prototype.complete = function(e, xhr, status) {
    var $target = $(e.target);
    $target.trigger("ajaxify:complete", [e, xhr, status]);

    if (this.button) {
      this.setButtonText();
      this.button = null;
    }
  };

  Ajaxify.prototype.error = function(e, xhr, status, error) {
    var $target = $(e.target);
    this.sucessActionFactory = new SuccessActionsFactory(e, xhr.responseJSON);
  };      

  SuccessActionsFactory = SAF = function(e, data) {
    var type;
    
    if (!data || !e) {return;}
    
    type = data.type;
    this.data = data;
    this.event = e;
    
    if (this[type]) {
      this[type]();
    }
  };
  
  SAF.prototype.redirect = function() {
    var $selector = $(this.event.target);
    $window.trigger("analytics", [$selector, "success", {redirect: this.data.location}]);
    if( this.data.location.match(/\?refresh\=true$/) ) {
      window.location = this.data.location;
    } else {
      Turbolinks.visit(this.data.location);
    }
  };
  
  SAF.prototype.success = function() {
    var eventNamespace = this.event.currentTarget.getAttribute("id") || null;
    var $form = $("form[data-formuuid="+this.data.formuuid+"]");
    var formErrors = new window.R.forms.Errors($form, [], this.data);
    var $selector = $(this.event.target);

    formErrors.clearErrors();

    $window.trigger("ajaxify:success", this);
    $form.trigger("ajaxify:success", this);

    if (eventNamespace) {
      $window.trigger("ajaxify:success:"+eventNamespace, this);
    }

    $window.trigger("analytics", [$selector, "success"]);
  };

  SAF.prototype.onsuccess = function() {
    var data = this.data,
        eventNamespace = data.params.name || this.event.currentTarget.getAttribute("id");

    if (eventNamespace) {
      $window.trigger("ajaxify:success:"+eventNamespace, this);
    }
  };

  SAF.prototype.error = function() {
    var errors = this.data.errors,
        $form = $(this.event.target);
    
    var formErrors = new window.R.forms.Errors($form, errors, this.data);
    formErrors.renderErrors();

    $window.trigger("ajaxify:errors", [this.event.target.id, errors]);
    $window.trigger("analytics", [ $form, "error", {errors: errors} ]);
  };
  
  return Ajaxify;
})($window);
