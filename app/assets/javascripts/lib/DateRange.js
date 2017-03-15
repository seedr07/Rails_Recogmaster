window.R = window.R || {}; 
window.R.DateRange = (function($, window, body, undefined) {
  var D = function(options) {
    this.options = options || {};
    this.paramScope = this.options.paramScope;
    this.$container = options.container || $document
    this.loadLibraries(this.addEvents.bind(this));
  };
  
  D.prototype.loadLibraries = function(callback) {
    new window.R.Select2(function(){
      new window.R.DatePicker(callback.bind(this));
    }.bind(this)); 
  };

  D.prototype.addEvents = function() {
    this.bindDateRangeSelect();
    this.bindCustomDateRange();
  };

  D.prototype.removeEvents = function() {
    this.$container.off(R.touchEvent, ".date-range .button-group a");
    this.$container.off(R.touchEvent, ".date-range-select--1 input[type=submit]");
    this.$container.off('change', ".date-range-select select");
  };

  D.prototype.bindDateRangeSelect = function() {
    var that = this;

    // activate select2
    this.$container.find(".date-range-select select").select2();

    // bind selecting an option and redirecting
    this.$container.on('change', ".date-range-select.active select", function(){
      var $this = $(this);
      that.rangeSelected($this.find("option:selected").text(), $this.val());
    });

  }

  D.prototype.bindCustomDateRange = function() {
    this.$container.find('.date-range .datepicker').datepicker({
      format: "mm/dd/yyyy"
    });

    var that = this;

    this.$container.on(R.touchEvent, '.date-range-select--1 input[type=submit]', function(evt){
      evt.preventDefault();
      if(that.validateCustomDateRange())
        that.rangeSelected(null, that.getCustomDateRange());
      return false;
    })
  };

  D.prototype.visitPageWithParams = function(params) { 
    var url = window.R.utils.locationWithNewParams(params);

    if(this.options.refresh == 'turbolinks') {
      Turbolinks.visit(url);
    } else {
      window.location = url;
    }
  };

  D.prototype.rangeSelected = function(label, selectedValues) {
    if(typeof(selectedValues) === "string") {
      selectedValues = window.R.utils.paramStringToObject(selectedValues);
    }    

    // if selection will update view via ajax
    // update label immediately, rather than waiting 
    // for page refresh
    // also make sure the old option is not selected(if in another select)
    if(this.options.ajax) {
      this.setHeading(label);
      this.clearOldSelection();
    }

    if(this.options.rangeSelected) {
      this.options.rangeSelected.apply(selectedValues);
    } else {
      this.visitPageWithParams(selectedValues);
    }
    
  };

  D.prototype.validateCustomDateRange = function() {
    var $customDateRangeContainer = this.$container.find(".date-range-select--1");
    var startControl = $customDateRangeContainer.find('.form-control[name=from]');
    var endControl = $customDateRangeContainer.find('.form-control[name=to]');
    var valid = true;

    if(!startControl.val()) {
      startControl.css({border: "1px solid red"});
      valid = false;
    } else {
      startControl.css({border: "inherit"})
    }

    if(!endControl.val()) {
      endControl.css({border: "1px solid red"})
      valid = false;
    } else {
      endControl.css({border: "inherit"})
    }

    return valid;
  };

  D.prototype.getCustomDateRange = function() {
    var start, end, paramsObject;
    var $customDateRangeContainer = this.$container.find(".date-range-select--1");

    start = $customDateRangeContainer.find('.form-control[name=from]').val();
    end = $customDateRangeContainer.find('.form-control[name=to]').val();

    start = Date.parse(start) / 1000;
    end = Date.parse(end) / 1000;

    paramsObject = {start_date: start, end_date: end, interval: -1};

    if(this.paramScope) {
      for(var property in paramsObject) {
        if (paramsObject.hasOwnProperty(property)) {
          paramsObject[this.paramScope+"["+property+"]"] = paramsObject[property];
          delete paramsObject[property];
        }
      }
    }
    return paramsObject;
  };

  D.prototype.selectedRange = function() {
    var $selectedContainer = this.selectedContainer();
    if($selectedContainer.hasClass('date-range-select--1')) {
      return this.getCustomDateRange();
    } else {
      return window.R.utils.paramStringToObject($selectedContainer.find('select').val());
    }
  };

  D.prototype.selectedContainer = function() {
    return this.$container.find(".date-range-select.active");
  };

  D.prototype.setHeading = function(label) {
    var $selectedContainer = this.selectedContainer();
    var $heading = this.$container.find(".selected-heading *");

    if($selectedContainer.hasClass('date-range-select--1')) {
      var start, end;
      var $customDateRangeContainer = this.$container.find(".date-range-select--1");

      start = $customDateRangeContainer.find('.form-control[name=from]').val();
      end = $customDateRangeContainer.find('.form-control[name=to]').val();
      $heading.html(start+" - "+end)
    } else {
      $heading.html(label);        
    }    
  }
  
  D.prototype.clearOldSelection = function() {
    this.$container.find(".date-range-select:not(.active) select").each(function(){ $(this).select2('val',''); })
  }

  D.prototype.from = function() {
    return this.selectedRange()[this.scopedParam("start_date")];
  };

  D.prototype.to = function() {
    return this.selectedRange()[this.scopedParam("end_date")];
  };

  D.prototype.scopedParam = function(param) {
    if(this.paramScope) {
      return this.paramScope+"["+param+"]";
    } else {
      return param;
    }
  };
  return D;
  
})(jQuery, window, document.body);