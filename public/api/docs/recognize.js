(function(){
  // console.log('recognize customizations');
  var RecognizeSwaggerUi = function(api, ui) {
    this.api = api;
    this.ui = ui;
    this.$apiInfo = $("#api_info");
    this.$apiResources = $("#resources_container");
    this.$apisContainer = $(".recognize-nav ul.top-level-endpoints");

    this.loadApisIntoNav();

    $(document).on('click', "ul.top-level-info a", function(){ this.showInfo() }.bind(this))
    $(document).on('keyup', ".parameter[name='X-Auth-Email']", copyXAuthHeader);
    $(document).on('keyup', ".parameter[name='X-Auth-Network']", copyXAuthNetwork);

  }

  RecognizeSwaggerUi.prototype.loadApisIntoNav = function() {
    this.$apisContainer.html('');
    $.each(this.api.apisArray, this.addResourceToNav.bind(this))
  }

  RecognizeSwaggerUi.prototype.addResourceToNav = function(index, resource) {
    var $li = $("<li>");
    var resourceId = 'resource_'+resource.name
    var apiLink = $("<a>").text(resource.name).prop({'href':'#'+resourceId}).data('id', resourceId);

    apiLink.on('click', this.showResource.bind(this));

    apiLink.appendTo($li);
    $li.appendTo(this.$apisContainer);
  };

  RecognizeSwaggerUi.prototype.showResources = function() {
    this.$apiInfo.hide();
    this.$apiResources.show();
  };

  RecognizeSwaggerUi.prototype.showInfo = function() {
    this.$apiInfo.show();
    this.$apiResources.hide();
    this.ui.collapseAll();
  };

  RecognizeSwaggerUi.prototype.showResource = function(evt) {
    var $target = $(evt.target);
    this.showResources();
    $('#'+$target.data('id')+' h2 a').trigger('click');
  };

  function copyXAuthHeader() {
    var $input = $(this);
    $(".parameter[name='X-Auth-Email']").val($input.val());
  }  

  function copyXAuthNetwork() {
    var $input = $(this);
    $(".parameter[name='X-Auth-Network']").val($input.val());
  }  
  
  window.RecognizeSwaggerUi = RecognizeSwaggerUi;
})();