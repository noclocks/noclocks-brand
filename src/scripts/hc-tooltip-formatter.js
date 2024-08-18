var tooltipFormatter = function () {
  var points = this.points;

  var ys = [];
  var y = null;
  ys = points.map(function (el) {
    var out = null;
    y = el.y;
    if (y > 1000000) {
      out = Math.round(y / 100000) / 10;
      out = out.toLocaleString("en-US", {
        minimumFractionDigits: 1,
        maximumFractionDigits: 1,
      });
      out = out + "M";
    } else if (y > 1000) {
      out = Math.round(y / 100) / 10;
      out = out.toLocaleString("en-US", {
        minimumFractionDigits: 1,
        maximumFractionDigits: 1,
      });
      out = out + "K";
    } else if (y > 2) {
      out = y.toLocaleString("en-US", {
        minimumFractionDigits: 0,
        maximumFractionDigits: 0,
      });
    } else {
      out = y.toLocaleString("en-US", {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
      });
    }

    return out;
  });
  //console.log('ys2', ys)

  var html_out = "<b>RYE " + this.x.name + ":</b><br/>";
  var last_metric = "";

  var i;
  for (i = 0; i < points.length; i++) {
    if (points[i].series.userOptions.my_metric !== last_metric) {
      html_out +=
        "<b>" + this.points[i].series.userOptions.my_metric + " :<b><br/>";
      last_metric = this.points[i].series.userOptions.my_metric;
    }

    html_out +=
      '<span style="color:' +
      points[i].color +
      '">\u25CF ' +
      points[i].series.userOptions.my_group +
      ": </span>" +
      ys[i] +
      "<br/>";
  }

  return html_out;
};
