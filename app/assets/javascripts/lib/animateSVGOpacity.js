(function($, window, undefined) {
  var scrollTimer = 0, $window;
  window.R = window.R || {};
  window.R.patterns = window.R.patterns || {};


  window.R.patterns.AnimateSVGOpacity = function(selector) {
    $window = window.$window || $(window);
    this.$svg = $(selector);

    if (this.$svg.length === 0 || $window.width() < 768) {
      return;
    }

    this.$paths = this.$svg.find("path");
    this.numberOfPaths = this.$paths.length;

    if (this.numberOfPaths === 0) {
      return;
    }

    this.changeShapeColor();
    this.setInterval();

    $window.on("scroll", function() {
      clearTimeout(scrollTimer);
      scrollTimer = setTimeout(function() {
        if ($body.scrollTop() > 206) {
          clearInterval(this.interval);
          this.interval = -1;
        } else if (this.interval === -1) {
          this.setInterval();
        }
      }.bind(this), 700);
    }.bind(this));
  };

  window.R.patterns.AnimateSVGOpacity.prototype.setInterval = function() {
    this.interval = setInterval(function() {
      this.changeShapeColor();
    }.bind(this), 6000);
  };

  window.R.patterns.AnimateSVGOpacity.prototype.changeShapeColor = function() {
    var that = this,
        index = Math.ceil(Math.random()*(this.numberOfPaths/1.5)),
        maxNumber = 0,
        maxTimeout = 0,
        numOfItems = 8;

    if (index > (maxNumber = this.numberOfPaths-numOfItems)) {
      index = maxNumber;
    }

    for (var i = 0; i < numOfItems; i++) (function(i) {
      setTimeout(function() {
        var maxTimeout = 400+(i*200);
        var path = that.$paths[index+i];
        path.style.opacity = .8 - ((.1*i)/4);
        setTimeout(function() {
          path.style.opacity = 1;
        }, maxTimeout + 1000);
      }, maxTimeout );
    })(i);
  };

})(jQuery, window);