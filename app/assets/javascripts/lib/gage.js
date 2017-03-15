(function() {
  window.R = window.R || {}; 

  window.R.gage = function(selector) {
    var that = this;
    var items = [];
    $(selector).each(function(){
      var id = $(this).prop('id');
      items.push( initialize(id) );
    });

    return items;
  }

  function initialize(id) { 
    return new JustGage({
        id: id,
        value: $("#"+id).data('res'),
        min: 0,
        max: 100,
        symbol: "%",
        customSectors: [{
          color: "#FF0000",
          lo: 0,
          hi: 25
        },{
          color: "#FFff00",
          lo: 25,
          hi: 49,
        },{
          color: "#06ff00",
          lo: 49,
          hi: 75,
        },{
          color: "#41a0d9",
          lo: 75,
          hi: 100
        }]
    });
  };  
})();
