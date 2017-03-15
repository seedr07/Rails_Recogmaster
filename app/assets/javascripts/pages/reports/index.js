window.R = window.R || {};
window.R.pages = window.R.pages || {};

window.R.pages["reports-index"] = (function($, window, undefined) {
  return function() {
    this.pagelet = new window.R.Pagelet();
    this.dateRange = new window.R.DateRange({refresh: 'turbolinks'});
    
  }
})(jQuery, window);