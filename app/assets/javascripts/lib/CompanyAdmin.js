window.R = window.R || {};

window.R.CompanyAdmin = (function($, window, body, R, undefined) {
  
  var CompanyAdmin = function() {
    this.addEvents();
  };
    
  CompanyAdmin.prototype.addEvents = function() {
    this.setupDeptSelect();
    $document.bind("page:fetch", this.removeEvents.bind(this));
  };

  CompanyAdmin.prototype.setupDeptSelect = function() {
    new window.R.Select2(this.bindMenuDeptSelect);
  };

  CompanyAdmin.prototype.bindMenuDeptSelect = function() {
    var $select = $('#dept-select').select2();
    $select.on('select2:select', function(e) {
      var $this = $(this),
        queryObj,
        url;

      queryObj = window.R.utils.queryParams();
      queryObj[$this.prop('name')] = $this.val();
      queryParams = $.param(queryObj);

      url = window.location.pathname + "?" + queryParams;

      if (window.location.hash !== "")
        url += window.location.hash;

      window.location = url;

    });

  }

  CompanyAdmin.prototype.removeEvents = function() {
    $window.unbind("ajaxify:success:comment_add", this.add);
  };
  
  return CompanyAdmin;
  
})(jQuery, window, document.body, window.R);