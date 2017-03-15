window.R = window.R || {};
window.R.ui = window.R.ui || {};
window.R.ui.CloneInput = (function() {

  var CLASS_NAME = "clone-input";
  var parentCssClass = ".clone-wrapper";
  
  function generateId(id) {
    var clonedIndex = id.indexOf("-cloned-");
    if (clonedIndex > -1) {
      id = id.substring(0, clonedIndex);
    }
    return id + "-cloned-" + parseInt( Math.random() * 1000, 10 );
  }
  
  var CloneInput = function() {
    this.addEvents();
  };


  CloneInput.prototype.addEvents = function() {
    var that = this;
    
    $body.on("focus", "."+CLASS_NAME, function(e) {
      var $clone,
          $this = $(e.target),
          $parent = $this.parent(),
          isLast = !( $parent.next().length > 0 ),
          $previous = $parent.prev(),
          id,
          $input,
          $group;
      
      if ( isLast && ( $previous.length === 0 || $previous.length > 0 && $previous.find("."+CLASS_NAME).val().length > 0 ) ) {
        $group = $this.closest(".control-group");
        $clone = $group.clone(true);
        $input = $clone.find("input[type='text']");
        id = generateId( $input.attr("id") );
        $input.val("");
        $input.attr("id", id);
        $group.after($clone);
      }
    });
    
    $body.on("blur", "."+CLASS_NAME, function(e) {
      var hasValue = this.value.length,
          $this = $(this),
          $group = $this.closest(".control-group"),
          $next = $group.next(),
          hasClone = $next.length && $next.find("input[type='text']").hasClass(CLASS_NAME),
          $nextInput,
          $inputs = $("."+CLASS_NAME);
      
      if ($inputs.length > 1) {
        $("."+CLASS_NAME+":not(:last):not(:eq(-1))").each(function(i, el) {
          if ($(this).val() === "") {
            $(this).closest(".control-group").remove();
          }

        });
      }

    
      if (!hasValue && hasClone) {
        $(window).trigger("element:removed", this.id);
      }
    });

    $document.bind("page:fetch", this.removeEvents.bind(this));
  };

  CloneInput.prototype.removeEvents = function() {
    $("."+CLASS_NAME).off("blur").off("focus");
  };
  
  CloneInput.prototype.recreate = function(savedFormData) {
    var cloneIndex, originalEl, clonedEl, savedValue;
    
    for (var inputId in savedFormData) {
      if (savedFormData.hasOwnProperty(inputId)) {
        savedValue = savedFormData[inputId];
        
        cloneIndex = inputId.indexOf("-cloned-");
        if (cloneIndex > -1 && savedValue !== "") {
          originalEl = inputId.substring(0, cloneIndex);
          originalEl = $( document.getElementById(originalEl) );
          
          clonedEl = originalEl.clone(true);
          clonedEl.attr("id", inputId);
          clonedEl.val( savedValue );
          
          originalEl.after(clonedEl);
        }
      }
    }
  };
  
  return CloneInput;
})();
