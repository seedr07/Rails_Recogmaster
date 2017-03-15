R = window.R || {};
R.ui = R.ui || {};

R.ui.graph = function() {

  function plotHover (event, pos, item) {
    if (item) {
      if (previousPoint != item.dataIndex) {

        previousPoint = item.dataIndex;

        $("#tooltip").remove();
        var x = item.datapoint[0].toFixed(2),
        y = item.datapoint[1].toFixed(2);

        showTooltip(item.pageX, item.pageY,
        new Date(parseInt(x, 10)).toDateString()+"<br />"+parseInt(y, 10)+" "+item.series.label);
      }
    }
  }

  function showTooltip(x, y, contents) {
      $("<div id='tooltip'>" + contents + "</div>").css({
        position: "absolute",
        display: "none",
        top: y + 5,
        left: x + 5,
        border: "1px solid #ccc",
        padding: "2px",
        "background-color": "#ccc",
        opacity: 0.80
      }).appendTo("body").fadeIn(200);
    }

  // helper for returning the weekends in a period

  function weekendAreas(axes) {

    var markings = [],
    d = new Date(axes.xaxis.min);

    // go to the first Saturday

    d.setUTCDate(d.getUTCDate() - ((d.getUTCDay() + 1) % 7))
    d.setUTCSeconds(0);
    d.setUTCMinutes(0);
    d.setUTCHours(0);

    var i = d.getTime();

    // when we don't set yaxis, the rectangle automatically
    // extends to infinity upwards and downwards

    do {
      markings.push({ xaxis: { from: i, to: i + 2 * 24 * 60 * 60 * 1000 } });
      i += 7 * 24 * 60 * 60 * 1000;
    } while (i < axes.xaxis.max);

    return markings;
  }

  function getDataFromChoices(){
    var data = [];
    $("#series").find("input:checked").each(function () {
      var key = $(this).attr("value");
      if (key && datasets[key])
      data.push(datasets[key]);
    });
    return data;
  }

  function plotAccordingToChoices() {
    var data = getDataFromChoices();

    if (data.length > 0) {
      $.plot("#placeholder", data, options);        
    }
  }

  $("#series").find("input").click(plotAccordingToChoices);

  function yaxisOptions(maxY) {
    var defaultOpts = {
      borderWidth: 0,
      color: null,
      min: 0
    };

    var y1 = $.extend({}, defaultOpts, {position: "left"});
    var y2 = $.extend({}, defaultOpts, {position: "right"});
    if(maxY) {
      y1.max = maxY*1.2;
      y2.max = maxY*1.2;
    }
    return [y1, y2];
  }

  var options = {
    series: {
      lines: { show: true },
      points: { show: true }
    },
    xaxis: {
      mode: "time",
      tickLength: 5
    },
    yaxes: yaxisOptions(),
    selection: {
      mode: "x"
    },
    grid: {
      borderWidth: 0,
      backgroundColor: null,
      hoverable: true,
      tickColor: "rgb(230,230,230)"
    },
    legend: {
      show: true,
      container: "#legend"
    }
  };

  plotAccordingToChoices();

  // var plot = $.plot("#placeholder", d, options);
  var previousPoint = null;

  $("#placeholder").bind("plotselected", function (event, ranges) {
    var data = getDataFromChoices();

    var maxY = 0;

    $(data).each(function(){
      $(this.data).each(function(){
        if(this[0] >= ranges.xaxis.from && this[0] <= ranges.xaxis.to && this[1] > maxY) {
          maxY = this[1];
        }
      });
    });


    plot = $.plot("#placeholder", data, 
      $.extend(true, {}, options, {
        xaxis: {
          min: ranges.xaxis.from,
          max: ranges.xaxis.to
        },
        yaxes: yaxisOptions(maxY)
      })
    );

  });

  $("#overview").bind("plotselected", function (event, ranges) {
    plot.setSelection(ranges);
  });

  $("#placeholder").bind("plothover", plotHover);

  $("#reset").bind("click", function(evt){
    evt.preventDefault();
    var data = getDataFromChoices();      
    plot = $.plot("#placeholder", data, options);
  });

}