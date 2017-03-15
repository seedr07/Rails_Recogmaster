window.R.pages["users-index"] = (function($, window, body, R, undefined) {
  var T = function() {
    this.addEvents();
  };
  
  T.prototype.addEvents = function() {
    this.$container = $("#user-list");
    var that = this;
    this.$container.infinitescroll(
      {
        pathParse: function(path, page){ 
          return path.match(/^(.*?)\b2\b(?!.*\b2\b)(.*?$)/).slice(1) 
        },
        animate: false,
        bufferPx: 600,
        loadingText  : "",
        navSelector  : '.pagination',    // selector for the paged navigation 
        nextSelector : '.pagination .next_page',  // selector for the NEXT link (to page 2)
        itemSelector : '.user-list li',     // selector for all items you'll retrieve
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
        that.$container.append(newElements);
      }
    );
  };

  T.prototype.removeEvents = function() {
    if (this.$container) {
      this.$container.infinitescroll("destroy");
    }
    delete this.$container;
  };
  
  
  return T;
})(jQuery, window, document.body, window.R);