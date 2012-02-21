class @app.BarchartPanel extends @app.Delegator

  #
  #
  # options - 
  #   width: 
  #   height:
  #   maxSectorFrequency:
  #

  constructor: (element, options) ->

    _.defaults options, height: 700, width: 700, barchart_height: 40, barchart_bar_width: 20

    @selection = d3.select(element).append("svg")
      .attr("width", options.width)
      .attr("height", options.height)

    @charts = []

    super @selection.node(), options

  #
  # sector - The currently selected sector's datum.
  # data   - An array of object literals containing the following keys.
  #   nodeName   : The sector node name (e.g 'MAT/07', )
  #   colour     : The colour currently used in the graph to highlight a given sector
  #   frequencies: A hash specifying the the amount of PhD grants allocated to this sector for each cycle.
  #
  #

  render: (sector, data) ->
    # TODO: Prepend the currently selected sector datum to this array
    data = data.sort (a, b) -> b.frequencies[app.ciclo] - a.frequencies[app.ciclo]

    drawableCharts = Math.round (@options.height / @options.barchart_height)
    yCoords = (@options.barchart_height * n for n in [0..drawableCharts - 1])

    defaultsOptions = 
      height: @options.barchart_height
      bar_width: @options.barchart_bar_width
      maxSectorFrequency: @options.maxSectorFrequency
      sector: sector

    for y in yCoords
      @charts.push (new app.Barchart @element, _.extend y:y, defaultsOptions)

    for index, datum of data
      @charts[index].render(datum)

    this


  clear: ->
    chart.remove() for chart in @charts
    @charts = []
    this






