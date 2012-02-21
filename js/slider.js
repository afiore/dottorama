(function() {
  var eventHandlers;

  eventHandlers = {
    mouseup: {
      showOutput: function(event) {
        return this.container.querySelector("output").value = event.target.value;
      },
      updateGraph: function(event) {
        app.ciclo = event.target.value;
        return this.graph.update();
      }
    }
  };

  this.app.Slider = (function() {

    function Slider(selector, graph) {
      var _this = this;
      this.selector = selector;
      this.graph = graph;
      this.element = document.querySelector(this.selector);
      this.container = this.element.parentNode;
      this.element.addEventListener("mouseup", function(event) {
        return app.utils.applyAll(_.values(eventHandlers.mouseup), [event], _this);
      });
    }

    return Slider;

  })();

  this.app.__defineGetter__("ciclo", function() {
    return app._ciclo || 19;
  });

}).call(this);
