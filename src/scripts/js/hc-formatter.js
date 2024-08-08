// highcharts-formatter.js

/**
 * Highcharts formatter function for RYE data
 *
 * This function formats the tooltip for the Highcharts graph.
 * It formats the y-axis values to be more human-readable.
 *
 * @returns {string} HTML string
*/

var hc_formatter = function () {
  var points = this.points;
  var ys = points.map(function (el) {
    var y = el.y;
    var out = null;
    if (y > 1000000) {
      out =
        (Math.round(y / 100000) / 10).toLocaleString("en-US", {
          minimumFractionDigits: 1,
          maximumFractionDigits: 1,
        }) + "M";
    } else if (y > 1000) {
      out =
        (Math.round(y / 100) / 10).toLocaleString("en-US", {
          minimumFractionDigits: 1,
          maximumFractionDigits: 1,
        }) + "K";
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

  var html_out = "<b>RYE " + this.x.name + ":</b><br/>";
  var last_metric = "";
  for (var i = 0; i < points.length; i++) {
    if (points[i].series.userOptions.my_metric !== last_metric) {
      html_out +=
        "<b>" + points[i].series.userOptions.my_metric + " :</b><br/>";
      last_metric = points[i].series.userOptions.my_metric;
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

/**
* @example
* From R Shiny:
 ui <- fluidPage(
   tags$head(
     tags$script(src = "js/highcharts-formatter.js")
   ),
   highchartOutput("chart")
 )

 server <- function(input, output) {
   output$chart <- renderHighchart({
     highchart() %>%
      hc_chart(type = "column") %>%
      hc_title(text = "Custom Tooltip Formatter Example") %>%
      hc_xAxis(categories = c("Jan", "Feb", "Mar")) %>%
      hc_yAxis(title = list(text = "Value")) %>%
      hc_tooltip(shared = TRUE, formatter = JS("hc_formatter")) %>%
      hc_add_series(name = "Series 1", data = c(1050, 2500, 750000), my_metric = "Metric 1", my_group = "Group A") %>%
      hc_add_series(name = "Series 2", data = c(2.5, 1.5, 0.75), my_metric = "Metric 2", my_group = "Group B")
 })
*/
