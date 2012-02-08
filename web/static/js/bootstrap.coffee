bootstrap = ->
  app.api.fetchDistributions().then (data) ->
    (new app.SunburstGraph data).render()
    data

  .end

document.addEventListener "DOMContentLoaded", bootstrap
