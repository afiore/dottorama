callApi = (url) ->
  deferred = Q.defer()
  d3.json url, (data) -> deferred.resolve(data)
  deferred.promise

occurrencyAverages = null

@app = 
  api:
    fetchDistributions: (ciclo = 19) ->
      callApi("/data/distributions.json").then (data) ->
        name: "Root", children: data


    fetchOccurencies: (value, ciclo=19) ->
      this._fetchOccurencyAverages(ciclo).then (average) ->
        value = encodeURIComponent(value.replace(/\//g,'-'))
        callApi("/data/#{value}_co-occurrencies.json").then (data) ->
          [data[ciclo.toString()], average]


    _fetchOccurencyAverages: (ciclo = 19) ->
      deferred = Q.call -> occurrencyAverages || callApi "/data/_average_co-occurencies.json"
      deferred.then (data) ->
        occurrencyAverages = data
        data[ciclo]

@app.__defineGetter__ "ciclo", -> @_ciclo || "19"
@app.__defineSetter__ "ciclo", (ciclo) -> @_ciclo = ciclo
