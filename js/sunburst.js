(function() {
  var arcTween, getArea, sectorValue, stash,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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

}).call(this);
