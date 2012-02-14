bootstrap = ->

  # Fetch data and render graph
  app.api.fetchDistributions().then (data) ->
    graph  = new app.SunburstGraph(data).render()

    #perhaps the slider should be hidden
    slider = new app.Slider "#ciclo-slider", graph

    data
  .end

  # initialise the slider widget


document.addEventListener "DOMContentLoaded", bootstrap
