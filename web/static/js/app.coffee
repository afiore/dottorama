callApi = (url) ->
  deferred = Q.defer()
  d3.json url, (data) -> deferred.resolve(data)
  deferred.promise


@app = 
  api:
    fetchDistributions: (ciclo = 19) ->
      callApi("/distributions/#{ciclo}").then (data) ->
         name: "Root", children: data

    fetchOccurencies: (attribute, value, ciclo=19) ->
      value = encodeURIComponent(value)
      callApi("/co_occurrencies/#{attribute}/#{value}/#{ciclo}")
