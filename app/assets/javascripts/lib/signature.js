(function() {
  $.fn.copyText = function(target) {
    var $target = $(target);
    if ($target.length === 0) {return;}

    $(this).keyup(function() {
      copyText(this.value);
    });

    copyText(this.value);

    function copyText(text) {
      $target.text(text);
    }
  };

})();