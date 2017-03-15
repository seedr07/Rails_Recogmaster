(function() {
    var tourID = R.pointsTourId;
    var tour = {
      id: tourID+"Hopscotch",
      steps: [
        {
          title: "Points redesigned",
          content: "A new stats page creates friendly competition between teams and users. Now see your points and your team's points for the last month. <strong>Points reset each month for an equal playing field.</strong>",
          target: "#header-reporting",
          placement: "bottom"
        },
        {
          title: "Your month's points",
          content: "Your profile now shows the interval and the total points for that interval. The interval can change to quarterly, monthly, or weekly by company admin for business package users. <a href=http://blog.recognizeapp.com/employee-recognition-points-redesigned-for-stronger-employee-engagement>Learn more</a>.",
          target: "#header-profile-wrapper",
          placement: "left"
        }

      ],
      onClose: function() {
        createCookie(tourID, "true");
      },
      onEnd: function() {
        createCookie(tourID, "true");
      }
    };

    if (readCookie(tourID) !== "true") {
      hopscotch.startTour(tour);
    }
    
})();
