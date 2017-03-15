(function() {
    window.recognize = window.recognize || {};
    window.recognize.pages = window.recognize.pages || {};
    window.recognize.pages["users-show"] = userProfile;
    var tabEl = "#column-two .column-two-left:nth-child(1) .yj-scrollbar-fix";

    function userProfile() {
        var that = this;

        window.recognize.file.load("/templates/users-show.html");

        this.yammerId = jQuery("[data-userid]").data("userid");

        that.createUserTab();

        recognize.ajax({
            url: recognize.file.getPath("templates/"+window.recognize.pageID+".html"),
            success: function(html) {
                $body.append( jQuery(html) );
            }
        });

        this.createRecognitionLink();

        this.addEvents();

        jQuery(".header-actions").css("min-width", "389px");

    }

    userProfile.prototype.createUserTab = function() {
      var html, $parent;
      if (jQuery("#recognition-tab-trigger").length > 0) {
        return;
      }

      html = '<li id="recognition-tab-trigger" class="yj-filter-tab"><a href="" class="yj-filter-tab-link">'+window.recognize.patterns.i18n().recognize+'</a></li>';
      $parent = jQuery("#column-two .column-two-left")

      this.$recognitionTabTrigger = jQuery( html );

      jQuery(".yj-action-bar-with-tabs .yj-tabs").append( this.$recognitionTabTrigger );

      this.$recognitionTab = jQuery("<div id='recognition-tab' class='yj-scrollbar-fix' style='display: none;'><div id='recognition-tab-content'><h2>"+window.recognize.patterns.i18n().loading+"</h2></div></div>");

      this.$recognitionContent = this.$recognitionTab.find("#recognition-tab-content");

      $parent = $parent.length > 1 ? $parent.eq(1) : $parent.eq(0);

      $parent.append( this.$recognitionTab );
    };

    function getURL() {
        return  window.recognize.patterns.api.endPoint+"/recognitions";
    }

    userProfile.prototype.showTab = function() {

        this.$recognitionTab.siblings().hide();

        this.$recognitionTab.show();

        jQuery(".yj-tabs .yj-selected").removeClass("yj-selected");

        this.$recognitionTabTrigger.addClass("yj-selected");
    };

    userProfile.prototype.hideTab = function() {
        this.$recognitionTab.siblings().show();
        this.$recognitionTab.hide();
        this.$recognitionTabTrigger.removeClass("yj-selected");
    };

    userProfile.prototype.triggerTab = function() {
        this.showTab();
        
        data = "yammer_id="+this.yammerId;

        var gettingRecognitions = window.recognize.patterns.api.get("/recognitions", data);

        gettingRecognitions.done(this.loadRecognitions.bind(this));
        gettingRecognitions.fail(this.noRecognitions.bind(this));

    };

    userProfile.prototype.loadRecognitions = function(data) {
        var hbTemplate = Handlebars.compile( jQuery("#recognitions-template").html() );
        var html = hbTemplate(data.recognitions);
        this.$recognitionContent.html(html);
    };

    userProfile.prototype.noRecognitions = function(data) {
        var error = JSON.parse(data.responseText);
        this.$recognitionContent.html(error.message);
    };

    userProfile.prototype.addEvents = function() {
        var that = this;

        this.$recognitionTabTrigger.click(function(e) {
            e.preventDefault();
            that.triggerTab();
        });

        jQuery(".yj-tabs li:not(#recognition-tab-trigger) a").click(function() {
            jQuery(this).parent("li").addClass("yj-selected");
            that.hideTab();
        });

        $body.on("click", "#user-recognize-trigger", this.openRecognitionOverlay.bind(this));
    };

    userProfile.prototype.openRecognitionOverlay = function(e) {
        recognize.patterns.recognitionForm.open(this.yammerId);
    };

    userProfile.prototype.createRecognitionLink = function() {
      if (jQuery("#user-recognize-trigger").length === 0 && jQuery(".header-actions .yj-edit-profile").length === 0 && this.yammerId) {
        jQuery(".header-actions").prepend('<a id="user-recognize-trigger" href="javascript://" class="yj-btn yj-btn-alt  yj-btn-profile-inline" style="margin-left: 3px;"><span>'+window.recognize.patterns.i18n().send_recognition+'</span></a>');
      }
    };
})();