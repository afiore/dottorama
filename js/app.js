(function() {
  var distributionAverages, fetchDataset, occurrencyAverages;

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
        })) || fetchDataset("/data/_average_distributions.json");
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
        return fetchDataset("/data/distributions.json").then(function(data) {
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
          return fetchDataset("/data/" + value + "_co-occurrencies.json").then(function(data) {
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

}).call(this);
