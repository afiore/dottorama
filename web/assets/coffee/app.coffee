callApi = (url) ->
  deferred = Q.defer()
  d3.json url, (data) -> deferred.resolve(data)
  deferred.promise

@app = 
  api:
    fetchDistributions: (ciclo = 19) ->
      callApi("/data/distributions.json").then (data) ->
        name: "Root", children: data

    fetchOccurencies: (value, ciclo=19) ->
      value = encodeURIComponent(value.replace(/\//g,'-'))
      callApi("/data/#{value}_co-occurrencies.json").then (data) ->
        data[ciclo.toString()]

@app.__defineGetter__ "ciclo", -> @_ciclo || "19"
@app.__defineSetter__ "ciclo", (ciclo) -> @_ciclo = ciclo
