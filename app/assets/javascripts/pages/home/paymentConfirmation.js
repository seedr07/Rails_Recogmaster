window.R = window.R || {};

window.R.paymentConfirmation = function() {
  var inputHelpers = window.R.forms.CreditCardValidation("#payment-form", submit);
  var stripeTimer = 0;

  function setStripe() {
    if (window.Stripe && $("#stripe-key").length > 0) {
      clearTimeout(stripeTimer);
      Stripe.setPublishableKey( $("#stripe-key").prop('content') );
    } else {
      stripeTimer = setTimeout(setStripe, 50);
    }
  }

  setStripe();

  function submit(form) {
      var $form = $(form);
      // remove the input field names for security
      // we do this *before* anything else which might throw an exception
      inputHelpers.removeInputNames(); // THIS IS IMPORTANT!

      // given a valid form, submit the payment details to stripe
      $(form['submit-button']).attr("disabled", "disabled")

      Stripe.createToken({
          number: $('.card-number').val(),
          cvc: $('.card-cvc').val(),
          exp_month: $('.card-expiry-month').val(),
          exp_year: $('.card-expiry-year').val()
      }, function(status, response) {
          if (response.error) {
              // re-enable the submit button
              $(form['submit-button']).removeAttr("disabled");

              // show the error
              $(".payment-errors").html(response.error.message);

              // we add these names back in so we can revalidate properly
              inputHelpers.addInputNames();
          } else {
              // token contains id, last4, and card type
              var token = response['id'];

              // insert the stripe token
              var input = $("<input name='subscription[stripe_card_token]' value='" + token + "' type=hidden />");
              $form.append(input);

              if ($form.data("remote") === true) {
                $.rails.handleRemote( $form );
              } else {
                form.submit();
              }
          }
      });
      
      return false;
  }
};