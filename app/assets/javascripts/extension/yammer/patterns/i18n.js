(function() {
  var finalSet;

  var baseSet = {
    "recognize": "Recognise",
    "stats": "Stats",
    "company_admin": "Company Admin",
    "send_recognition": "Send Recognition",
    "sign_in": "Sign In to Recognize",
    "loading": "Loading..."
  };

  var fullSet = {
    "en-US": function() {
      var thisSet = baseSet;
      thisSet.recognize = "Recognize";
      return thisSet;
    },
    "fr": {
      "recognize": "Reconnaissance",
      "stats": "Statistiques",
      "company_admin": "Bilan de l'enterprise",
      "send_recognition": "Envoyer",
      "sign_in": "Ouvrir une session",
      "loading": "chargement"
    }
  };

  window.recognize = window.recognize || {};
  window.recognize.patterns = window.recognize.patterns || {};
  window.recognize.patterns.i18n = function() {
    var languageSet;
    var browserLanguage = navigator.language ? navigator.language : navigator.userLanguage;
    browserLanguage = browserLanguage || "en";

    if (finalSet) {
      if (typeof finalSet === "function") {
        return finalSet();
      } else {
        return finalSet;
      }
    }

    for (languageSet in fullSet) {
      if (!fullSet.hasOwnProperty(languageSet)) {
        return;
      }

      if (browserLanguage.toLowerCase().indexOf(languageSet.toLowerCase()) > -1) {
        finalSet = fullSet[languageSet];
      }
    }

    finalSet = !finalSet ? baseSet : finalSet;

    if (typeof finalSet === "function") {
      return finalSet();
    } else {
      return finalSet;
    }
  };

})();