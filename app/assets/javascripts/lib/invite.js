window.R = window.R || {};
window.R.pages = window.R.pages || {};

window.R.pages["users-invite"] = (function($, window, body, R, undefined) {
  var I = function() {
    this.cloneInput = new R.ui.CloneInput();
    this.$yammerButton = $(".button-yammer-signup");
    
    this.addEvents();
    
  };
  
  I.prototype.addEvents = function() {
    $body.on(R.touchEvent, ".person", this.selectYammerUser);
    this.getSuggestedYammerUsers();
  };
  
  I.prototype.selectYammerUser = function(e) {
    var $el = $(this), 
        id, 
        selected = "selected";
        
    if ($el.hasClass(selected)) {
      $el.removeClass(selected);
      $el.find(".checkbox").prop("checked", "");
    } else {
      id = $el.data("id");
      $el.addClass(selected);
      $el.find(".checkbox").prop("checked", "checked");

    }
    
  };
  
  I.prototype.inviteUsersFromYammer = function() {
    var that = this;
    var counter = 0, limit;
    if (!window.R.y) {
      this.y = window.R.y = new window.Yammer(function(e) {
        var userList = {},
            groupIds = [],
            counter = 0, 
            limit,
            currentUser = this.currentUser = e.user;
        
        this.$yammerButton.text("Loading users");
                  
        this.y.getCurrentUserGroups(function(groups) {
          limit = groups.length;
          groups.forEach(function(group) {
            that.y.getGroupById(group.id, function(group) {
              var usersCounter = 0;
              counter++;
              
              group.users.forEach(function(user) {
                if (user.id !== currentUser.id) {
                  usersCounter++;
                  userList[user.id] = {
                    name: user.full_name,
                    img: user.mugshot_url
                  };
                }
              });
              
              if (limit === counter) {
                that.appendYammerUsers(userList);
                if (usersCounter < 50) {
                  that.getMoreYammerUsers(userList);
                }
              }
            });
              
          });
            
        }.bind(this));
      }.bind(this), undefined, function(error) {
        console.log(error);
      });
    }
  };
  
  I.prototype.appendYammerUsers = function(userList) {
    var compiledYammerUsers = [];
    
    for (var user in userList) {
      if (userList.hasOwnProperty(user)) {
        compiledYammerUsers.push("<div class=person data-id="+user+"><i class=icon-ok icon-white></i><img src="+userList[user].img+"/><h4>"+userList[user].name + "</h4></div>");
      }
    }

    $("#invite-inner").append($(compiledYammerUsers.join("")));
    this.$yammerButton.hide();
          
    $("#invite-yammer-users").removeClass("hidden");
  }
  
  I.prototype.getMoreYammerUsers = function(appendedUsers) {
    var limit = 50 - appendedUsers.length;
    
    var html, yammerUsers = [];
    
    this.y.getUsers(function(users) {
      users.forEach(function(user, i) {
        if (!appendedUsers[user.id] && user.id !== this.currentUser.id) {
          yammerUsers[user.id] = {
            name: user.full_name,
            img: user.mugshot_url
          };
        }
      }.bind(this));
      
      this.appendYammerUsers(yammerUsers);
          
    }.bind(this), function(error) {});
  };

  I.prototype.getSuggestedYammerUsers = function() {
    $.ajax({
        url: '/'+$body.data("name")+'/get_suggested_yammer_users',
        type: "GET",
        success: function(data){
          $("#yammer-invite-suggestions-wrapper").hide().html(data).fadeIn();
        }
    });    
  };
  // I.prototype.getSuggestedYammerUsers = function() {
  //   $.get('/users/get_suggested_yammer_users', function(data){
  //     $("#yammer-invite-suggestions-wrapper").hide().html(data).fadeIn();
  //   });
  // };

  return I;
})(jQuery, window, document.body, window.R);