window.R = window.R || {};
window.R.pages = window.R.pages || {};

window.R.pages["hall_of_fame-index"] = (function() {

  var H = function() {
    this.scrollingElement = ".time-periods-wrapper";
    this.checkAllArrows();
    this.addEvents();
  };

  H.prototype.checkAllArrows = function() {
    var that = this;
    $(this.scrollingElement).each(function() {
      that.checkArrows(this);
    });
  };

  H.prototype.addEvents = function() {
    var that = this;
    var timer = 0;

    $(document).on("click", ".arrow-clip", function(e) {
      var pageWidth = $(window).width();
      var $scrolling = $(this).closest(that.scrollingElement);
      e.preventDefault();
      $scrolling.animate({
        scrollLeft: ( $(this).hasClass("arrow-clip-right") ? $scrolling.scrollLeft() + pageWidth : $scrolling.scrollLeft() - pageWidth )
      })
    });

    $(this.scrollingElement).on("scroll", function() {
      var el = this;
      clearTimeout(timer);
      timer = setTimeout(function() {
        that.checkArrows(el);
      }, 30);
    });

    new window.R.Select2(bindSelect2);

  };

  H.prototype.checkArrows = function(el) {
    var $el = $(el);
    var scrolledAmount = el.scrollWidth - $(document).width() - el.scrollLeft;

    if ( $el.find(".time-period:last-child").offset().left + $(el).scrollLeft() + 150 <= $(window).width() ) {
      return $el.find(".arrow-clip, .arrow-clip-left").addClass("hidden");
    }

    if (scrolledAmount < 200 ) {
      $el.find(".arrow-clip-right").addClass("hidden");
    } else {
      $el.find(".arrow-clip-right").removeClass("hidden");
    }

    if (el.scrollLeft > 10) {
      $el.find(".arrow-clip-left").removeClass("hidden");
    } else {
      $el.find(".arrow-clip-left").addClass("hidden");
    }
  };

  H.prototype.removeEvents = function() {
    $('.param-select').off('select2:select');
  }
  
  function bindSelect2() {
    var $selects = $('.param-select').select2();
    $selects.on('select2:select', function(e){ 
      var $this = $(this), 
          queryObj;

      if($this.data('reset-tools')) { 
        queryObj = {};
        queryObj[$this.prop('name')] = $this.val();

        // also manually carry over viewer
        var viewer = window.R.utils.queryParams()['viewer']
        if(viewer) {
          queryObj['viewer'] = viewer;
        }

      } else {
        queryObj = window.R.utils.queryParams();
        queryObj[$this.prop('name')] = $this.val();
      }

      Turbolinks.visit(window.location.pathname+"?"+$.param(queryObj));

    });
  }

  return H;

})();