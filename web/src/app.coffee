fetchDataset = (url) ->
  deferred = Q.defer()
  d3.json url, (data) -> deferred.resolve(data)
  deferred.promise

occurrencyAverages = null
distributionAverages = null

@app = 
  api:
    fetchDistributionAverage: (ciclo=19) ->
      deferred = (distributionAverages && Q.call -> distributionAverages) || fetchDataset("data/average_distributions.json")
      deferred.then (data) ->
        distributionAverages = data
        maxVal = _.max (maxFreq for cycle, [maxFreq] of data )
        maxVal

    fetchDistributions: (ciclo = 19) ->
      fetchDataset("data/distributions.json").then (data) ->
        name: "Root", children: data

    fetchOccurencies: (value, ciclo=19) ->
      this._fetchOccurencyAverages(ciclo).then (average) ->
        value = encodeURIComponent(value.replace(/\//g,'-'))
        fetchDataset("data/#{value}_co-occurrencies.json").then (data) ->
          [data[ciclo.toString()], average]

    _fetchOccurencyAverages: (ciclo = 19) ->
      deferred = (occurrencyAverages && Q.call -> occurrencyAverages) || fetchDataset "data/average_co-occurencies.json"
      deferred.then (data) ->
        occurrencyAverages = data
        data[ciclo]

@app.__defineGetter__ "ciclo", -> @_ciclo or "19"
@app.__defineSetter__ "ciclo", (ciclo) -> @_ciclo = ciclo
