(function() {
  var bootstrap;

  bootstrap = function() {
    return app.api.fetchDistributions().then(function(data) {
      app.api.fetchDistributionAverage(19).then(function(maxValue) {
        var graph, panel, slider;
        panel = new app.BarchartPanel("#barchart-panel", {
          maxSectorFrequency: maxValue
        });
        graph = new app.SunburstGraph(data, "#chart", {
          barchartPanel: panel
        }).render();
        slider = new app.Slider("#ciclo-slider", graph);
        return null;
      }, function(error) {
        throw error;
      }).end();
      return data;
    }, function(error) {
      throw error;
    }).end();
  };

  document.addEventListener("DOMContentLoaded", bootstrap);

}).call(this);
