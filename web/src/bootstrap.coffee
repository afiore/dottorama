bootstrap = ->

  # initialise the slider widget
  # Fetch data and render graph
  app.api.fetchDistributions().then( (data) ->
    app.api.fetchDistributionAverage(19).then((maxValue) ->

      panel = new app.BarchartPanel "#barchart-panel", maxSectorFrequency: maxValue
      graph  = new app.SunburstGraph(data, "#chart", barchartPanel: panel).render()
      slider = new app.Slider "#ciclo-slider", graph:graph

      null
    , (error) -> throw error ).end()

    data
  , (error) -> throw error ).end()






document.addEventListener "DOMContentLoaded", bootstrap
