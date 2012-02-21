(function() {
  var __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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

}).call(this);
