(function() {
  window.recognize = window.recognize || {};
  window.recognize.patterns = window.recognize.patterns || {};
  window.recognize.patterns.overlay = {
    init: init,
    open: open,
    close: close
  };

  var template;
  var $overlay;

  function init(callback) {
    recognize.ajax({
        url: recognize.file.getPath('templates/overlay.html'),
        success: function(html) {

            $body.append(jQuery(html));
            template = Handlebars.compile(jQuery('#r-overlay').html());

            if (callback) {
              callback();
            }

        }.bind(this)
    });

    $body.on('click', '.r-overlay-wrapper #yj_cboxClose', close);
  }

  function open(title, body, size) {
    var overlayHTML, position, completeOpen, width, height;

    if (size === "full") {
      width = jQuery(window).width() - 50;
      height = jQuery(window).height();
    } else {
      width = 624;
      height = 500;
    }

    completeOpen = function() {
      $overlay = jQuery('.r-overlay-wrapper');

      overlayHTML = template({
        title: title,
        content: body
      });

      close();

      $body.append(jQuery(overlayHTML));

      center(width, height);
    };

    if (!template) {
      init(function() {
        completeOpen();
      });
    } else {
      completeOpen();
    }
  }

  function close() {
    if ($overlay.length > 0) {
      $overlay.remove();
    }
  }

  function center(width, height) {
    $overlay = jQuery('.r-overlay-wrapper').removeClass('r-hidden');
    width = width || $overlay.width();
    height = height || $overlay.height();

    $overlay.css({
      'width': width + 'px',
      'height': height + 'px',
      'margin-top': (-(height / 2)) + 'px',
      'margin-left': (-(width / 2)) + 'px'
    });

  }
})();
