window.R = window.R || {};

window.R.Cards = (function($, window, body, R, undefined) {
  var timer = 0;
  var tappedRecognitionCard;
  var canCloseMenu = true;
  
  var Cards = function($container, callback) {
    this.$container = $container;
    this.callback = callback || function() {};
    this.addEvents();
  };
  
  Cards.prototype.openMenu = function(e) {
    if (canCloseMenu) {
      canCloseMenu = false;
      $(this).closest(".recognition-card").toggleClass("options-open");
      setTimeout(function() {
        $body.trigger("recognition:change");
      }, 100);

      setTimeout(function() {
        canCloseMenu = true;
      }, 500);
    }
  };

  function startIsotope($container) {
    $container.isotope({
      itemSelector : '.recognition-card',
      masonryHorizontal: { columnWidth: "90%"},
      sortAscending : true,
      resizable: false, // disable normal resizing
      getSortData : {
        popular : function ( $elem ) {
          return ($elem.attr("data-popular")).slice(1);
        }
      }
    });
  }
  
  Cards.prototype.initIsotope = function($container, callback) {
    var timer = 0;
    startIsotope($container);

    $window.smartresize(function() {
      clearTimeout(timer);
      timer = setTimeout(function() {
        startIsotope($container);
      }, 500);

    });

    $container.infinitescroll(
      {
        pathParse: function(path, nextPage){ 
          // var re = new RegExp('^(.*?page=)'+nextPage+'(\/.*|$)');    
          var re = new RegExp('(.*?page=)'+nextPage+'(.*$)');
          path = path.match(re).slice(1);                                       
          return path;
        },
        animate: false,
        bufferPx: -1000,
        loadingText  : "",
        navSelector  : '.pagination',    // selector for the paged navigation 
        nextSelector : '.pagination .next_page',  // selector for the NEXT link (to page 2)
        itemSelector : '.recognition-card',     // selector for all items you'll retrieve
        loading: {
          finishedMsg: 'No more recognitions to load.',
          finished: function() {
            $("#infscr-loading").remove();
            NProgress.done();
          }
        },
        errorCallback: NProgress.done
      },
      // call Isotope as a callback
      function( newElements ) {
        var $newElements = $( newElements );
        $container.isotope( 'appended', $newElements);
        if (!Modernizr.backgroundsize) {
          $(".recognition-card .image-wrapper").css("background-size", "150px");
        }
      }
    );

    if (callback) {
      callback();
    }
  };

  Cards.prototype.orientationChange = function(e) {
    var $el = $(e.target), className = "";

    if ($el.data("orientation") === "vertical") {
      $("#recognitions-wrapper").addClass("vertical").removeClass("stacked");
    } else {
      $("#recognitions-wrapper").addClass("stacked").removeClass("vertical");
    }

    $body.trigger("recognition:change");
  };

  Cards.prototype.addEvents = function() {
    $body.bind("recognition:change", function() {
      $(".isotope").isotope("reLayout");
    });

    this.initIsotope(this.$container, this.callback);

    $body.on(R.touchEvent, ".card-layout", this.orientationChange.bind(this));

    $body.on("click", '.cancel-edit', function(e){
      var $form = $(e.target).parents('form.edit_recognition');
      $form.closest(".edit-open").removeClass("edit-open");
      $form.remove();
      $body.trigger("recognition:change");
      e.preventDefault();
    });
    
    this.$container.on(R.touchEvent, ".options-trigger", this.openMenu);
    
    $(document).bind("page:fetch", this.unload.bind(this));
  };

  Cards.prototype.unload = function() {
    $(document)
    .off(R.touchEvent, ".recognition-card")
    .off(R.touchEvent, '.cancel-edit');

    if (this.$container) {this.$container.off(R.touchEvent, ".options-trigger");}
    $(document).unbind("recognition:change");
    if (this.$container) {
      this.$container.infinitescroll("destroy");
    }
    delete this.$container;

    $(document).unbind("page:fetch", this.unload.bind(this));
  };
  
  return Cards;
  
})(jQuery, window, document.body, window.R);