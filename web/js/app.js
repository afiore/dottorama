(function() {
  var arcTween, bootstrap, distributionAverages, fetchDataset, getArea, getDatum, getFrequencies, height, occurrencyAverages, sectorValue, stash,
    __slice = Array.prototype.slice,
    _this = this,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  fetchDataset = function(url) {
    var deferred;
    deferred = Q.defer();
    d3.json(url, function(data) {
      return deferred.resolve(data);
    });
    return deferred.promise;
  };

  occurrencyAverages = null;

  distributionAverages = null;

  this.app = {
    api: {
      fetchDistributionAverage: function(ciclo) {
        var deferred;
        if (ciclo == null) ciclo = 19;
        deferred = (distributionAverages && Q.call(function() {
          return distributionAverages;
        })) || fetchDataset("data/_average_distributions.json");
        return deferred.then(function(data) {
          var cycle, maxFreq, maxVal;
          distributionAverages = data;
          maxVal = _.max((function() {
            var _results;
            _results = [];
            for (cycle in data) {
              maxFreq = data[cycle][0];
              _results.push(maxFreq);
            }
            return _results;
          })());
          return maxVal;
        });
      },
      fetchDistributions: function(ciclo) {
        if (ciclo == null) ciclo = 19;
        return fetchDataset("data/distributions.json").then(function(data) {
          return {
            name: "Root",
            children: data
          };
        });
      },
      fetchOccurencies: function(value, ciclo) {
        if (ciclo == null) ciclo = 19;
        return this._fetchOccurencyAverages(ciclo).then(function(average) {
          value = encodeURIComponent(value.replace(/\//g, '-'));
          return fetchDataset("data/" + value + "_co-occurrencies.json").then(function(data) {
            return [data[ciclo.toString()], average];
          });
        });
      },
      _fetchOccurencyAverages: function(ciclo) {
        var deferred;
        if (ciclo == null) ciclo = 19;
        deferred = (occurrencyAverages && Q.call(function() {
          return occurrencyAverages;
        })) || fetchDataset("/data/_average_co-occurencies.json");
        return deferred.then(function(data) {
          occurrencyAverages = data;
          return data[ciclo];
        });
      }
    }
  };

  this.app.__defineGetter__("ciclo", function() {
    return this._ciclo || "19";
  });

  this.app.__defineSetter__("ciclo", function(ciclo) {
    return this._ciclo = ciclo;
  });

  getDatum = function(element) {
    return element.__data__;
  };

  this.app.Delegator = (function() {

    function Delegator(element, options) {
      this.element = element;
      this.options = options != null ? options : {};
      if (typeof this.element === "string") {
        this.element = document.querySelector(this.element);
      }
      this.bindEvents();
    }

    Delegator.prototype.bindEvents = function() {
      var event, functionName, sel, selector, _i, _ref, _ref2, _results;
      if (!this.events) return;
      _ref = this.events;
      _results = [];
      for (sel in _ref) {
        functionName = _ref[sel];
        _ref2 = sel.split(" "), selector = 2 <= _ref2.length ? __slice.call(_ref2, 0, _i = _ref2.length - 1) : (_i = 0, []), event = _ref2[_i++];
        _results.push(this.addEvent(selector.join(' '), event, functionName));
      }
      return _results;
    };

    Delegator.prototype.addEvent = function(selector, eventName, functionName) {
      var closure,
        _this = this;
      closure = function() {
        return _this[functionName].apply(_this, arguments);
      };
      return this.element.addEventListener(eventName, function(event) {
        var selection;
        selection = selector ? _this.element.querySelectorAll(selector) : [_this.element];
        if (_.include(selection, event.target)) {
          return closure(event, getDatum(event.target));
        }
      });
    };

    return Delegator;

  })();

  app.utils = {
    applyAll: function(funcs, args, binding) {
      if (binding == null) binding = null;
      return _.each(funcs, function(func) {
        return func.apply(binding || _this, args);
      });
    }
  };

  this.app.Slider = (function(_super) {

    __extends(Slider, _super);

    Slider.prototype.events = {
      "mouseup": "onMouseUp"
    };

    function Slider(element, options) {
      Slider.__super__.constructor.call(this, element, options);
      this.graph = options.graph;
    }

    Slider.prototype.onMouseUp = function(event) {
      var container;
      container = event.target.parentElement;
      container.querySelector("output").value = event.target.value;
      app.ciclo = event.target.value;
      return this.graph.update();
    };

    return Slider;

  })(this.app.Delegator);

  getArea = function(d) {
    while (d.parent && d.parent.name !== 'Root') {
      d = d.parent;
    }
    return d;
  };

  stash = function(d) {
    d.fill0 = d3.select(this).style("fill");
    d.x0 = d.x;
    return d.dx0 = d.dx;
  };

  arcTween = function(a) {
    var i;
    i = d3.interpolate({
      x: a.x0,
      dx: a.dx0
    }, a);
    return function(t) {
      var b;
      b = i(t);
      a.x0 = b.x;
      a.dx0 = b.dx;
      return arc(b);
    };
  };

  sectorValue = function(d) {
    var _ref;
    return (d != null ? (_ref = d.frequencies) != null ? _ref[app.ciclo] : void 0 : void 0) || 0;
  };

  this.app.SunburstGraph = (function(_super) {

    __extends(SunburstGraph, _super);

    SunburstGraph.prototype.events = {
      "path mouseover": "onMouseover",
      "path mouseout": "onMouseout",
      "path click": "onClick",
      "path mousemove": "onMousemove"
    };

    function SunburstGraph(data, element, options) {
      var r;
      this.data = data;
      this.element = element != null ? element : "#chart";
      this.options = options != null ? options : {};
      _.defaults(this.options, {
        width: 700,
        height: 700
      });
      r = Math.min(this.options.width, this.options.height) / 2;
      this.vis = d3.select(this.element).append("svg").attr("width", this.options.width).attr("height", this.options.height).append("g").attr("transform", "translate(" + this.options.width / 2 + "," + this.options.height / 2 + ")");
      this.partition = d3.layout.partition().sort(function(a, b) {
        var _ref;
        return (b != null ? (_ref = b.frequencies) != null ? _ref[app.ciclo] : void 0 : void 0) - a.frequencies[app.ciclo] || 1;
      }).size([2 * Math.PI, r * r]).value(sectorValue);
      this.arc = d3.svg.arc().startAngle(function(d) {
        return d.x;
      }).endAngle(function(d) {
        return d.x + d.dx;
      }).innerRadius(function(d) {
        return Math.sqrt(d.y);
      }).outerRadius(function(d) {
        return Math.sqrt(d.y + d.dy);
      });
      this.tooltip = new app.Tooltip({
        graph: this
      });
      this.barchartPanel = this.options.barchartPanel;
      this.setColourScales();
      SunburstGraph.__super__.constructor.call(this, this.element, this.options);
    }

    SunburstGraph.prototype.render = function() {
      var _this = this;
      this.vis.data([this.data]).selectAll("path").data(this.partition.nodes).enter().append("g");
      this.vis.selectAll("g").append("path").attr("display", function(d) {
        if (d.depth && d.depth < 3) {
          return null;
        } else {
          return "none";
        }
      }).attr("d", this.arc).attr("fill-rule", "evenodd").style("stroke", "#fff").style("fill", function(d) {
        var level;
        if (!(d.depth > 0)) return;
        d = getArea(d);
        level = _this.colourScales.level(d.frequencies[app.ciclo]);
        return "hsl(0, 0%, " + level + "%)";
      }).each(stash);
      return this;
    };

    SunburstGraph.prototype.setColourScales = function() {
      var child, name, sectorNames, sectorValues;
      sectorNames = (function() {
        var _i, _len, _ref, _results;
        _ref = this.data.children;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          name = _ref[_i].name;
          _results.push(name);
        }
        return _results;
      }).call(this);
      sectorValues = ((function() {
        var _i, _len, _ref, _results;
        _ref = this.data.children;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          child = _ref[_i];
          _results.push(sectorValue(child));
        }
        return _results;
      }).call(this)).sort(function(a, b) {
        return b - a;
      });
      return this.colourScales = {
        hue: d3.scale.ordinal().domain(sectorNames).rangePoints([0, 359]),
        level: d3.scale.ordinal().domain(sectorValues).rangeRoundBands([0, 100])
      };
    };

    SunburstGraph.prototype.update = function() {
      var _this = this;
      this.setColourScales();
      return this.vis.selectAll("path").data(this.partition.value(sectorValue)).transition().duration(1000).style("fill", function(d) {
        var level;
        d = getArea(d);
        level = _this.colourScales.level(sectorValue(d));
        return "hsl(0, 0%, " + level + "%)";
      }).attrTween("d", function(a) {
        var i;
        i = d3.interpolate({
          x: a.x0,
          dx: a.dx0
        }, a);
        return function(t) {
          var b;
          b = i(t);
          a.x0 = b.x;
          a.dx0 = b.dx;
          return _this.arc(b);
        };
      });
    };

    SunburstGraph.prototype.onMouseover = function(event, d) {
      if (!d.active) this._colouriseSector(d);
      return this.tooltip.show(d);
    };

    SunburstGraph.prototype.onMouseout = function(event, d) {
      if (!d.active) this._downlightSector(d);
      return this.tooltip.hide();
    };

    SunburstGraph.prototype.onClick = function(event, d) {
      var _this = this;
      this._downlightAll();
      return this._fetchRelatedSectors(d).then((function(data) {
        var d1;
        d1 = _.clone(d);
        d1.colour = d3.hsl(_this.colourScales.hue(d.parent.name), 1, 0.5).toString();
        _this.barchartPanel.clear().render(d1, data);
        return null;
      }), function(error) {
        throw error;
      });
    };

    SunburstGraph.prototype.onMousemove = function(event) {
      return this.tooltip.move(event);
    };

    SunburstGraph.prototype._colouriseSector = function(d) {
      var area, elementColour;
      area = getArea(d);
      if (d.depth === 1) d = area;
      elementColour = d3.hsl(this.colourScales.hue(area.name), 1, 0.5);
      this.vis.selectAll("path").filter(function(dd) {
        return dd === d || dd.parent === d;
      }).style("fill", elementColour.toString());
      return this;
    };

    SunburstGraph.prototype._downlightSector = function(d) {
      this.vis.selectAll("path").filter(function(dd) {
        return dd === d || dd.parent === d;
      }).style("fill", function(dd) {
        return dd.fill0;
      });
      return this;
    };

    SunburstGraph.prototype._downlightAll = function(d) {
      this.vis.selectAll("path").style("fill", function(d) {
        return d.fill0;
      }).each(function(d) {
        return d.active = false;
      });
      return this;
    };

    SunburstGraph.prototype._fetchRelatedSectors = function(d) {
      var _this = this;
      return app.api.fetchOccurencies(d.name, app.ciclo).then(function(args) {
        var average, count, data, nodes, output, relevant, sector;
        output = [];
        data = args[0], average = args[1];
        relevant = (function() {
          var _results;
          _results = [];
          for (sector in data) {
            count = data[sector];
            if (count >= average) _results.push([sector, count]);
          }
          return _results;
        })();
        nodes = (function() {
          var _i, _len, _ref, _results;
          _results = [];
          for (_i = 0, _len = relevant.length; _i < _len; _i++) {
            _ref = relevant[_i], sector = _ref[0], count = _ref[1];
            _results.push(sector);
          }
          return _results;
        })();
        _this.vis.selectAll('path').filter(function(node) {
          return nodes.indexOf(node.name) > -1;
        }).style("fill", function(d) {
          var colour, parent;
          parent = getArea(d);
          colour = d3.hsl(_this.colourScales.hue(parent.name), 1, 0.5).toString();
          output.push({
            colour: colour,
            name: d.name,
            frequencies: d.frequencies,
            co_occurencies: data[d.name]
          });
          return colour;
        }).each(function(d) {
          return d.active = true;
        });
        return output;
      });
    };

    return SunburstGraph;

  })(this.app.Delegator);

  height = null;

  getFrequencies = function(datum) {
    var cycle, value, _ref, _results;
    _ref = datum.frequencies;
    _results = [];
    for (cycle in _ref) {
      value = _ref[cycle];
      _results.push(value);
    }
    return _results;
  };

  this.app.Barchart = (function(_super) {

    __extends(Barchart, _super);

    function Barchart(element, options) {
      if (options == null) options = {};
      _.defaults(options, {
        height: 30,
        bar_width: 30,
        colour: "grey"
      });
      height = d3.scale.linear().domain([0, parseInt(options.maxSectorFrequency)]).rangeRound([0, options.height]);
      this.selection = d3.select(element).append("g").attr("class", "barchart");
      Barchart.__super__.constructor.call(this, this.selection.node(), options);
    }

    Barchart.prototype.render = function(datum) {
      var data, heights, node,
        _this = this;
      data = getFrequencies(datum);
      heights = [];
      this.selection.selectAll("rect").data(data).enter().append("rect").attr("x", function(d, i) {
        return i * _this.options.bar_width;
      }).attr("y", function(d, i) {
        return _this.options.y + _this.options.height - height(d);
      }).attr("width", this.options.bar_width).attr("height", function(d) {
        var h;
        h = height(d);
        heights.push(h);
        return h;
      });
      this.selection.append("rect").attr("x", function() {
        return (app.ciclo - 19) * _this.options.bar_width;
      }).attr("y", function() {
        return _this.options.y + _this.options.height - height(datum.co_occurencies);
      }).attr("width", this.options.bar_width).attr("height", function() {
        return height(datum.co_occurencies);
      }).style("fill", this.options.sector.colour);
      node = this.selection.append("text").attr("x", function() {
        return (data.length * _this.options.bar_width) + 10;
      }).attr("y", function() {
        return _this.options.y;
      }).append("tspan").text(datum.name).style("font-size", 12).style("fill", "#fff").node();
      this.selection.append("rect").attr("height", 18).attr("width", function() {
        return datum.name.trim().length * 10;
      }).attr("x", function() {
        return (data.length * _this.options.bar_width) + 8;
      }).attr("y", function() {
        return _this.options.y + 25;
      }).style("fill", datum.colour);
      return this;
    };

    Barchart.prototype.remove = function() {
      var parent;
      parent = this.element.parentElement;
      return parent.removeChild(this.element);
    };

    return Barchart;

  })(this.app.Delegator);

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

  this.app.Tooltip = (function(_super) {

    __extends(Tooltip, _super);

    function Tooltip(options) {
      if (options == null) options = {};
      this.selection = d3.select("body").append("div").attr("class", "tooltip");
      this.graph = options.grap;
      Tooltip.__super__.constructor.call(this, this.selection.node(), options);
    }

    Tooltip.prototype.show = function(d) {
      var area, colour, text, _ref;
      text = d.human_name || d.name;
      text += " ( " + (d != null ? (_ref = d.frequencies) != null ? _ref[app.ciclo] : void 0 : void 0) + ")";
      area = d.depth === 1 && d || (d != null ? d.parent : void 0);
      if (d.depth === 1) d = area;
      colour = d3.hsl(this.options.graph.colourScales.hue(area.name), 1, 0.5);
      if (d && text) {
        this.selection.text(text).style("visibility", "visible").style("background", colour.toString());
      }
      return this;
    };

    Tooltip.prototype.hide = function() {
      this.selection.style("visibility", "hidden");
      return this;
    };

    Tooltip.prototype.move = function(event) {
      this.selection.style("top", (event.pageY - 10) + "px").style("left", (event.pageX + 10) + "px");
      return this;
    };

    return Tooltip;

  })(this.app.Delegator);

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
        slider = new app.Slider("#ciclo-slider", {
          graph: graph
        });
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
