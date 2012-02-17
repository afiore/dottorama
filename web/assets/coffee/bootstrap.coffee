bootstrap = ->

  # initialise the slider widget
  # Fetch data and render graph
  app.api.fetchDistributions().then( (data) ->
    app.api.fetchDistributionAverage(19).then((maxValue) ->

      barchart = new app.Barchart "#barchart", maxValue: maxValue, height: 150, bar_width: 20
      graph  = new app.SunburstGraph(data, "#chart", barchart: barchart).render()

      #perhaps the slider should be hidden
      slider = new app.Slider "#ciclo-slider", graph
      null
    , (error) -> throw error ).end()


    data
  , (error) -> throw error ).end()






document.addEventListener "DOMContentLoaded", bootstrap
