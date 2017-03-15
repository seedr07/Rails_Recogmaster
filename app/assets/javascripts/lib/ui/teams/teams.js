window.Teams = (function($, window, body, undefined) {
  var t = function() {
    this.$teams = $("#teams");
    //this.$input = $("#add-team-input");
    //this.$list = this.$teams.find(".team-list");
    //this.$button = $("#add-team");
  };
  
  t.prototype.addEvents = function() { 
    var that = this;  
    /*$("#add-team-input").keyup(function(e){
      var value = $(this).val();
      e.preventDefault();
      that.$button.data('params', {team: {name: value}});
    });*/
  };
  
  t.prototype.appendTeam = function(teamHTML) {
    /*this.$list.prepend(teamHTML);
    this.$input.val("");*/
  };
  
  return t;

})(jQuery, window, document.body);