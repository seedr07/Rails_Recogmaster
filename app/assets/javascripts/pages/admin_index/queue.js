window.R = window.R || {};
window.R.pages = window.R.pages || {};

window.R.pages["admin_index-queue"] = (function($, window, undefined) {
  function showTable(evt, showdiv, hidediv) {
    evt.preventDefault();
    $(showdiv).show();
    $(hidediv).hide();
  }

  $('#active-queue').click(function(e){showTable(e, '#active_jobs', '#failed_jobs');});
  $('#failed-queue').click(function(e){showTable(e, '#failed_jobs', '#active_jobs');});

  return function() {
  };
})(jQuery, window);
