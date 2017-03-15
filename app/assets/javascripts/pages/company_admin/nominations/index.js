window.R = window.R || {};
window.R.pages = window.R.pages || {};

window.R.pages["company_admin_nominations-index"] = (function() {

  var N = function() {
    this.addEvents();
  };

  N.prototype.addEvents = function() {
    var that = this;
    this.dateRange = new window.R.DateRange({refresh: 'turbolinks'});

  };

  N.prototype.removeEvents = function() {
  }
  
  return N;

})();