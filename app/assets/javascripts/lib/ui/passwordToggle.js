R.ui.passwordToggle = (function($, window, body, undefined) {

  return function($parent, target) {
    var targetElement = document.getElementById(target);
    $input = $parent.find(".on-off");
    $input.iOSCheckbox({
      onChange: function() {
        var type = "text";
        var checkedAttribute = $input.attr("checked");
        if (!checkedAttribute) {
          type = "password";
        }

        targetElement.setAttribute("type", type);
      }
    });
  }

})(jQuery, window, document.body);