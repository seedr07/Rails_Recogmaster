window.simpleAutocomplete = (function(window, undefined) {
  var SA = function(element, config) {
    var defaultOpts;
    this.$element = $(element);
    this.endpoint = this.$element.data('endpoint');
    this.responseRootNode = this.$element.data('responserootnode');
    this.itemLabelAttribute = this.$element.data('itemlabelattribute');
    this.itemUrlAttribute = this.$element.data('itemurlattribute');

    defaultOpts = {
      delay: 100,
      minLength: 3,
      source: function(request, response) {
        $.getJSON(this.endpoint, {q: request.term}, function(data){
          var array = data.error ? [] : $.map(data[this.responseRootNode], function(item){
            return {
              label: item[this.itemLabelAttribute],
              url: item[this.itemUrlAttribute]
            }
          }.bind(this))
          response(array);
        }.bind(this));
      }.bind(this)
    };
    
    this.$element.autocomplete($.extend(defaultOpts, config)).autocomplete("widget").addClass('simple-autocomplete')
  }

  return SA;
})();