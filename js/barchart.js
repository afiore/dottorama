(function() {
  var getFrequencies, height,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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
      }).style("stroke", "none");
      this.selection.append("rect").attr("x", function() {
        return (app.ciclo - 19) * _this.options.bar_width;
      }).attr("y", function() {
        return _this.options.y + _this.options.height - height(datum.co_occurencies);
      }).attr("width", this.options.bar_width).attr("height", function() {
        return height(datum.co_occurencies);
      }).style("fill", this.options.sector.colour).style("stroke", "none");
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

}).call(this);
