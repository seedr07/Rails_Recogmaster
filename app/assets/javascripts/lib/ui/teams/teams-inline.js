window.Teams.Inline = (function($, window, body, undefined) {
  
  var t = function() {
    t.superclass.constructor.apply(this, arguments);
    this.addEvents();
  };
  
  R.utils.inherits(t, Teams);
  
  t.prototype.addEvents = function() {
    t.superclass.addEvents.apply(this, arguments);
    /*var $teamsForm = this.$teams.find("form");
    
    $body.on(R.touchEvent, "#add-team", function(e) {
      this.add(e);
    }.bind(this));

    $body.on(R.touchEvent, "#teams .thumbnail", function() {
      $teamsForm.submit();
    }.bind(this));
    
    if ($teamsForm.length) {
      this.$teams.closest("form").submit(function(e) {
        if ( $("#add-team-input:focus").length ) {
          e.preventDefault();
          this.add(e);
          return false;
        }
      }.bind(this));
    } else {
      this.$input.keyup(function(e) {
        if (e.keyCode === 13) {
          e.preventDefault();
          this.add(e);
        }
      });
    }*/
  };

  t.prototype.removeEvents = function() {
    //$body.off(R.touchEvent, "#add-team");
    //$body.off(R.touchEvent, "#teams .thumbnail");
  };
  
  t.prototype.add = function(e) {
    /*var $teams = this.$teams;
    var value = this.$input.val();

    if (value === "") {
     return false;
    }

    // TODO use handle bars
    var html = '<li>'+
     '<div class="thumbnail">'+
     '<label>'+
       '<input type="checkbox" value="" checked="checked" name="user[team_names][]">'+
       '<div class="button button-primary">'+
        ' <i class="icon-ok icon-white"></i>'+
         '<span></span>'+
     '  </div>'+
     '</label>'+
    '  </div>'+
    ' </li>';

    html = $(html);

    html.find(".button span").text(value);
    html.find("input").val(value);

    this.appendTeam(html);*/
  };
  
  return t;
 
})(jQuery, window, document.body);