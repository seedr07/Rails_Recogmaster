window.R = window.R || {};
window.R.pages = window.R.pages || {};

window.R.pages["redemptions-index"] = (function() {
  var RedemptionsIndex = function() {
    this.addEvents();
  }

  RedemptionsIndex.prototype.addEvents = function() {
    $window.bind("ajaxify:success:updatedRewards", function(evt, response){
      this.rewardRedeemed(evt, response)
    }.bind(this));
  }

  RedemptionsIndex.prototype.rewardRedeemed = function(evt, response) {
    var $form = $("form[data-formuuid='"+response.data.formuuid+"']");
    var $wrapper = $form.parents(".reward-card");
    $wrapper.removeClass("redeemable").addClass("redeemed");

    $wrapper.find(".reward-form-wrapper").hide();

    $wrapper.addClass("redeemed-success");

    this.updatePointTotals(response.data.params.redeemable_points);

  };

  RedemptionsIndex.prototype.updatePointTotals = function(points) {
      $(".redeemable_points_total").html(points);
      $(".reward").each(function(){
        var $this = $(this);
        var pointsNeeded = -(points - parseInt($this.data('points')));
  
        if(pointsNeeded > 0) {
          $this.removeClass("redeemable").addClass("unredeemable");
          $this.find(".points-needed").html(pointsNeeded);

        } else {
          $this.removeClass("unredeemable").addClass("redeemable");

        }
      });    
  }
  return RedemptionsIndex;

})();