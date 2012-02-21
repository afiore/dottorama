(function() {
  var _this = this;

  app.utils = {
    applyAll: function(funcs, args, binding) {
      if (binding == null) binding = null;
      return _.each(funcs, function(func) {
        return func.apply(binding || _this, args);
      });
    }
  };

}).call(this);
