(function() {
  var __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  this.app.BarchartPanel = (function(_super) {

    __extends(BarchartPanel, _super);

    function BarchartPanel(element, options) {
      _.defaults(options, {
        height: 700,
        width: 700,
        barchart_height: 40,
        barchart_bar_width: 20
      });
      this.selection = d3.select(element).append("svg").attr("width", options.width).attr("height", options.height);
      this.charts = [];
      BarchartPanel.__super__.constructor.call(this, this.selection.node(), options);
    }

    BarchartPanel.prototype.render = function(sector, data) {
      var datum, defaultsOptions, drawableCharts, index, n, y, yCoords, _i, _len;
      data = data.sort(function(a, b) {
        return b.frequencies[app.ciclo] - a.frequencies[app.ciclo];
      });
      drawableCharts = Math.round(this.options.height / this.options.barchart_height);
      yCoords = (function() {
        var _ref, _results;
        _results = [];
        for (n = 0, _ref = drawableCharts - 1; 0 <= _ref ? n <= _ref : n >= _ref; 0 <= _ref ? n++ : n--) {
          _results.push(this.options.barchart_height * n);
        }
        return _results;
      }).call(this);
      defaultsOptions = {
        height: this.options.barchart_height,
        bar_width: this.options.barchart_bar_width,
        maxSectorFrequency: this.options.maxSectorFrequency,
        sector: sector
      };
      for (_i = 0, _len = yCoords.length; _i < _len; _i++) {
        y = yCoords[_i];
        this.charts.push(new app.Barchart(this.element, _.extend({
          y: y
        }, defaultsOptions)));
      }
      for (index in data) {
        datum = data[index];
        this.charts[index].render(datum);
      }
      return this;
    };

    BarchartPanel.prototype.clear = function() {
      var chart, _i, _len, _ref;
      _ref = this.charts;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        chart = _ref[_i];
        chart.remove();
      }
      this.charts = [];
      return this;
    };

    return BarchartPanel;

  })(this.app.Delegator);

}).call(this);
