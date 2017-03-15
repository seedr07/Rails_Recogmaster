window.R = window.R || {};
window.R.pages = window.R.pages || {};

(function() {
  var S = function() {
    addPaymentMethodHandler();
    addLineItemHandler();
  };

  S.prototype.removeEvents = function() {
    $document.off('click.payment');
  };

  function addPaymentMethodHandler() {
    $document.on('click.payment', '.payment-method', function(evt){
      var $paymentMethod = $(this);
      if($paymentMethod.val() == "CreditCard")
        $("#start-date-wrapper").addClass('hidden');
      else
        $("#start-date-wrapper").removeClass('hidden');
    });
  }

  function addLineItemHandler() {
    $document.on('click.payment', '.remove_fields', function(evt) {
      var $this = $(this);
      $this.prev('input[type=hidden]').val('1');
      $this.closest('fieldset').hide();
      evt.preventDefault();
    });

    $document.on('click.payment', '.add_fields', function(evt) {
      var $this = $(this);
      var time = new Date().getTime();
      var regexp = new RegExp($(this).data('id'), 'g');
      $this.before($this.data('fields').replace(regexp, time));
      evt.preventDefault()
    });
  }

  window.R.pages["admin_subscriptions-new"] = S;
  window.R.pages["admin_subscriptions-edit"] = S;
})();

