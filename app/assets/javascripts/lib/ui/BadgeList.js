(function() {
  var $badgeList;
  window.R = window.R || {};
  window.R.ui = window.R.ui || {};
  window.R.ui.BadgeList = BadgeList;

  BadgeList.prototype = {
      addEvents: function() {
          var that = this;
          this.$badgeTrigger = $("#top .image-wrapper");
          $badgeList = $('#badge-list');

          this.$badgeTrigger.bind("click", function(e) {
              e.preventDefault();

              R.transition.fadeTop("#recognize-badge-list-wrapper");

              if ($window.width() > 768) {
                  $('#badge-list').isotope({
                      itemSelector : '.badge-item',
                      masonryHorizontal: {}
                  });
              }

              $("#best-wrapper").show();

          }.bind(this));

          $document.on("click", ".badge-item .button", function() {
              $(this).closest(".badge-item").click();
          });

          $document.on("click", ".badge-item", function(e) {
              var $badge = $(this).find(".badge-image-small");
              var badge = {
                  id: $badge.data("badge-id"),
                  name: $badge.data("name"),
                  relativeImagePath: $badge.data("relativeimagepath")
              };
              $("#recognition_badge_id").val(badge.id);
              $("#nomination_badge_id").val(badge.id);
              $(".image-wrapper").addClass("chosen");

              that.chooseBadge($(this));
          });

          $document.on("click", "#badge-list .badge-image-small", function(e) {
              $(this).siblings(".button").trigger(R.touchEvent);
          });
      },

      removeEvents: function() {
          if (this.$badgeTrigger) {this.$badgeTrigger.unbind("click");}
          $window.unbind("keyup");
      },

      closeOverlays: function() {
          R.transition.fadeTop("#recognition-new-wrapper");
      },

      chooseBadge: function($badgeButton) {
          if ( $badgeButton.attr("id") === "upgrade-badges-link-badge" ) {
              Turbolinks.visit($badgeButton.prop('href'));
          }

          var $badge = $badgeButton.find(".badge-image-small");
          var id = $badge.data("badge-id");
          var badge = {
              name: $badge.data("name"),
              className: $badge.data("cssclass"),
              relativeImagePath: $badge.data("relativeimagepath")
          };

          var largeBadgeWrapper = this.$badgeTrigger.find("#badge-trigger")[0];

          $("#"+this.type+"_badge_id").val(id);
          $(".subtle-text").removeClass("edit");

          $("#badge-edit").removeClass("hidden");

          this.$badgeTrigger.addClass("edited");

          // largeBadgeWrapper.className = "badge-image "+badge.className;
          largeBadgeWrapper.className = "";

          var $badgeImage = $("<img>");
          $badgeImage.attr('src',  badge.relativeImagePath);
          $(largeBadgeWrapper).html( $badgeImage );

          if ($html.hasClass("ie8")) {
              largeBadgeWrapper.className = largeBadgeWrapper.className.replace("badge-image", "badge-image-small");
          }

          $("#badge-name").text(badge.name).removeClass("subtle-text");

          if ($window.width() <= 690) {
              $("body, html").scrollTop(0);
          }
          this.closeOverlays();
      }
  };


function BadgeList(type) {
  this.type = type || "recognition";
  this.addEvents();
}


})();
