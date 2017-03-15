window.R = window.R || {};
window.R.forms = window.R.forms || {};

window.R.forms.CreditCardValidation = function(formId, callback) {
  function addInputNames() {
    // Not ideal, but jQuery's validate plugin requires fields to have names
    // so we add them at the last possible minute, in case any javascript 
    // exceptions have caused other parts of the script to fail.
    $(".card-number").attr("name", "card-number");
    $(".card-cvc").attr("name", "card-cvc");
    $(".card-expiry-year").attr("name", "card-expiry-year");
    $(".card-expiry-month").attr("name", "card-expiry-month");
  }
  function removeInputNames() {
    $(".card-number").removeAttr("name");
    $(".card-cvc").removeAttr("name");
    $(".card-expiry-year").removeAttr("name");
    $(".card-expiry-month").removeAttr("name");
  }
  addInputNames();

  if (!jQuery.validator) {return;}
  
  // add custom rules for credit card validating
  jQuery.validator.addMethod("cardNumber", Stripe.validateCardNumber, "Please enter a valid card number");
  jQuery.validator.addMethod("cardCVC", Stripe.validateCVC, "Please enter a valid security code");
  jQuery.validator.addMethod("cardExpiry", function() {
      return Stripe.validateExpiry( $(".card-expiry-month").val(), $(".card-expiry-year").val() );
  }, "Please enter a valid expiration");

  // We use the jQuery validate plugin to validate required params on submit
  $(formId).validate({
      submitHandler: callback,
      errorPlacement: function(error, element) {
        element.closest( ".control-group" ).prepend( error );
      },
      rules: {
          "card-cvc" : {
              cardCVC: true,
              required: true
          },
          "card-number" : {
              cardNumber: true,
              required: true
          },
          "card-expiry-year" : "cardExpiry" // we don't validate month separately
      }
  });

  return {
    addInputNames: addInputNames,
    removeInputNames: removeInputNames
  };
};
