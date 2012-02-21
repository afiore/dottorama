(function() {
  var getDatum,
    __slice = Array.prototype.slice;

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
        if (_.include(_this.element.querySelectorAll(selector), event.target)) {
          return closure(event, getDatum(event.target));
        }
      });
    };

    return Delegator;

  })();

}).call(this);
