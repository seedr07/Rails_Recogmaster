window.R = window.R || {};
window.R.pages = window.R.pages || {};

["nominations-edit", "nominations-create", "nominations-new_chromeless", "nominations-new"].forEach(function(page) {
  window.R.pages[page] = function() {
    return new window.R.ui.Post("nomination_vote", {
      createUsers: false
    });
  }
});