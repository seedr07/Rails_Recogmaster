window.R = window.R || {};
window.R.pages = window.R.pages || {};

window.R.pages["departments-index"] = (function() {

  var D = function() {
    this.addEvents();
  };


  D.prototype.addEvents = function() {
    new window.R.Select2(bindSelect2);
  };


  D.prototype.removeEvents = function() {
    $('select').off('select2:select');
  }
  
  function bindSelect2() {
    var $selects = $('select').select2({
      createTag: function (query) {
        return {
          id: query.term,
          text: query.term,
          tag: true
        }
      },
      tags: true       
    });
    $selects.on('select2:select', function(e){ 
      var $this = $(this);
      console.log($this);
      // if($this.data('reset-tools')) { 
      //   queryObj = {};
      //   queryObj[$this.prop('name')] = $this.val();
      // } else {
      //   queryObj = window.R.utils.queryParams();
      //   queryObj[$this.prop('name')] = $this.val();
      // }

      // Turbolinks.visit(window.location.pathname+"?"+$.param(queryObj));

    });
  }

  return D;

})();