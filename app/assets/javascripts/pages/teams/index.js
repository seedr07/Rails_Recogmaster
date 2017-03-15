window.R = window.R || {};
window.R.pages = window.R.pages || {};

window.R.pages["teams-index"] = (function() {
  var TeamsIndex = function() {

    this.teams = new window.Teams.Inline();

    this.addEvents();
  };

  TeamsIndex.prototype.addEvents = function() {
    var $directoryWrapper = $("#teams-directory-wrapper");
    var teamsDirectoryId = "#teams-directory";
    var newTeamId = "#new_team";
    var $teams = $("#teams");

    $teams
    .on("ajax:beforeSend", function(evt, xhr, opts){
      var newName = $(evt.target).find("input[type=text]").val();

      if(newName === "") {
        xhr.abort();
        return false;
      };

      var teamNames = $("#teams-directory .name h3").map(function(){return $(this).html().toLowerCase();});

      if($.inArray(newName.toLowerCase(), teamNames) > -1) {
        successFeedback("That team name already exists.", $("#inner-add"), 'text-warn');
        xhr.abort();
        return false;
      }

    })
    .on("ajaxify:complete", function() {
      $directoryWrapper.load(window.location.href + " " + teamsDirectoryId, function(){
        this.addResGauge();
      }.bind(this));

      $("#add-team-input").attr("value", "");
      successFeedback("Team Created", $("#inner-add"));
    }.bind(this));

    $directoryWrapper.on("ajax:success", "a.team-toggle", function(evt, xhr, opts){
      $directoryWrapper.load(window.location.href + " " + teamsDirectoryId);
      return false;
    });

    this.addResGauge();

  };

  TeamsIndex.prototype.removeEvents = function() {
    $("#new_team").unbind("ajaxify:complete");
    this.teams.removeEvents();
  };

  TeamsIndex.prototype.addResGauge = function() {
    var $resScores = $(".res-score");
    if ($resScores.children().length > 0) {
      $resScores.empty();
    }
    window.R.gage(".res-score");
  };

  function successFeedback(message, element, msgClass){
    var msgClass = msgClass || 'text-success';
    var $existingMessages = element.find(".team-create-success");
    $existingMessages.remove();
    var successMessage = '<span class="team-create-success '+msgClass+'">' + message + '</span>';
    element.append(successMessage);
    element.find(".team-create-success").fadeOut(4000);
  }

  return TeamsIndex;

})();