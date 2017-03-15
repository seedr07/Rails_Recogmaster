window.Autocomplete.recognizeAutocomplete = (function() {
  var emailTemplate = Handlebars.compile( $("#emailItem").html() );
  var userTemplate = Handlebars.compile( $("#userItem").html() );
  var teamTemplate = Handlebars.compile( $("#teamItem").html() );

  // Format autocomplete data from Yammer 
  // to confirm to the data expected by Recognize's handlebar templates
  // Need: 
  //    - avatar_thumb_url
  //    - label
  //    - network label
  function formatYammerUser(user) {
    var parentCompanyName = $body.data("parent-name");
    var person = user;

    person.label = user.full_name;
    person.avatar_thumb_url = user.photo;

    return person;
  }

  return {
    _renderMenu: function(ul, items) {
      var $html,
          itemsLength = items.length, 
          counter = 0, 
          person, 
          emailMetadata = items[items.length-1],
          personOrTeam;
      
      if (itemsLength >= 1) {
        while (counter < itemsLength) {
          var user = items[counter];
          var team;

          if (user.email) {
              if (R.userTeamMap && R.userTeamMap != null) {
                  team = R.userTeamMap[user.email];
              }


            // hack to massage autocomplete data from Yammer
            // to conform to the data expected by Recognize's handlebar templates 
            // person.web_url is only present when data comes from yammer
            person = user;
            if (user.web_url) {
              person = formatYammerUser(person);
            }

            if(team && team.length > 0) { 
              person.team = team;
            }

            if (person && !person.label) {
              person.first_name = person.email;
              person.last_name = null;
            }

            personOrTeam = $( userTemplate({items: person}) ).data("ui-autocomplete-item", person);

          } else if(user.id) {
            personOrTeam = $( teamTemplate({items: user}) ).data("ui-autocomplete-item", user);
          }

          if(user.type) {
            personOrTeam.addClass(user.type.toLowerCase());
          }

          if (personOrTeam) ul.append(personOrTeam);

          counter++;
        }
        
      }
      
      ul.append( $( emailTemplate( items[items.length-1] ) ).data("ui-autocomplete-item", {email: emailMetadata.value}) );
      
      return ul;
    }
  }
});