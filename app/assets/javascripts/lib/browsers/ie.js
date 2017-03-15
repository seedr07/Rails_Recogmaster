$window.load(function() {  
  $("#header-reporting div").css("background-size", "28px 25px");

  $("#header-stream div").css("background-size", "25px 25px");

  $("#header-recognize div").css("background-size", "25px 25px");
  
  $("#header-settings div").css("background-size", "25px 25px");

  if ($(".recognition-card .gear-big").length > 0) {
    $(".recognition-card .gear-big").css("background-size", "15px");
  }
  
  if ($(".recognition-card .gear-small").length > 0) {
    $(".recognition-card .gear-small").css("background-size", "10px");
  }
  
  if ($(".pen-link").length > 0) {
    $(".pen-link").css("background-size", "21px 14px");
  }

  $("#header-controls a div, #header-settings div").css({
    "background": "none"
  });
      
  $("#settings-menu a").css({
    "backgroundImage": "none",
    "paddingLeft": 0
  });
  
  $(".tab-nav li a").css("font-weight", "auto");
  
  $("html, body").focus();  
});
