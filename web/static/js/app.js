(function() {
  var callApi;

  callApi = function(url) {
    var deferred;
    deferred = Q.defer();
    d3.json(url, function(data) {
      return deferred.resolve(data);
    });
    return deferred.promise;
  };

  this.app = {
    api: {
      fetchDistributions: function(ciclo) {
        if (ciclo == null) ciclo = 19;
        return callApi("/distributions/" + ciclo).then(function(data) {
          return {
            name: "Root",
            children: data
          };
        });
      },
      fetchOccurencies: function(attribute, value, ciclo) {
        if (ciclo == null) ciclo = 19;
        value = encodeURIComponent(value);
        return callApi("/co_occurrencies/" + attribute + "/" + value + "/" + ciclo);
      }
    }
  };

}).call(this);
