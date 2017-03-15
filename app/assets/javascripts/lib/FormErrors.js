window.R = window.R || {};
window.R.forms = window.R.forms || {};

window.R.forms.Errors = (function($, window, body, R, undefined) {
 var FormErrors = function($form, errors, data) {
    this.$form = $form;
    this.errors = errors;
    this.data = data;
  };  

  FormErrors.prototype.setErrorText = function(errorText, element) {
    var $errorElement = $('<div class=error></div>');
    $errorElement.html("<h5>"+errorText+"</h5>");

    if(element === "base") {
      var $base = $("#base_errors");
      if($base.length === 0) {
        this.$form.prepend($errorElement.css("text-align", "center"));
      } else {
        $("#base_errors").before($errorElement.css("text-align", "center"));
      }
    } else {
      
      var elementSelector = "#"+element;
      if(this.data && this.data.formuuid) {
        $("form[data-formuuid="+this.data.formuuid+"]").find(elementSelector).before($errorElement);
      } else {
        if($(elementSelector).length === 0) {
          elementSelector +=("_"+this.data.id);
        }        
        $(elementSelector).before($errorElement);
      } 

    }
  }

  FormErrors.prototype.renderErrors = function() {

    this.clearErrors();
    
    for (var element in this.errors) {      
      if (this.errors.hasOwnProperty(element)) {
        
        if (this.errors[element].constructor === Array) {          
          this.errors[element].forEach(function(error) {
            this.setErrorText(error, element);
          }.bind(this));
        } else {
          this.setErrorText(this.errors[element], element);
        }
        
      }
    }

  }

  FormErrors.prototype.clearErrors = function() {
    this.$form.find(".error").remove();    
  }

  return FormErrors;
  
})(jQuery, window, document.body, window.R);