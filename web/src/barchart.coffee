height = null


getFrequencies = (datum) -> 
  value for cycle, value of datum.frequencies

class @app.Barchart extends @app.Delegator
  # Public:
  #
  # Initialises a barchart displaying sector frequencies per cycle.
  #
  # element - A selector identifying the container element within which the histogram should be rendered.
  # options - An option hash with the following values
  #   sector:    Datum of the currently selected sector.
  #   height:    Pixel height of the barchart (optional, defaults to ).
  #   bar_width: Pixel width of each bar (optional, defaults to ).
  #   maxValue:  The maximum sector frequency value in the entire dataset.
  #   y:         Position of the barchart's canvas in the Y axis.
  #
  # Returns nothing
  #

  constructor: (element, options = {}) ->
    _.defaults options, height: 30, bar_width: 30, colour: "grey"
    height = d3.scale.linear().domain([0, parseInt(options.maxSectorFrequency)]).rangeRound [0, options.height]

    @selection = d3.select(element).append("g").attr("class", "barchart")

    super @selection.node(), options

  # 
  # public:
  #
  # Renders the barchart.
  #
  # data - a d3 datum
  # 
  # Returns itself
  #

  render: (datum) ->
    data = getFrequencies datum
    heights = []

    @selection.selectAll("rect")
      .data(data)
      .enter().append("rect")
      .attr("x", (d, i) => i * @options.bar_width )
      .attr("y", (d, i) => @options.y + @options.height - height(d))
      .attr("width", @options.bar_width)
      .attr("height", (d) ->
        h = height(d); heights.push h; return h
      )

    # display co-occurrencies as an overlay
    @selection.append("rect")
      .attr("x", => (app.ciclo - 19) * @options.bar_width)
      .attr("y", => @options.y+ @options.height - height(datum.co_occurencies))
      .attr("width", @options.bar_width)
      .attr("height", => height(datum.co_occurencies))
      .style("fill", @options.sector.colour)

    # place a label with the sector name on the right end side of the barchart
    
    node = @selection.append("text")
      .attr("x", => (data.length * @options.bar_width) + 10 )
      .attr("y", => @options.y)
      .append("tspan").text(datum.name)
        .style("font-size", 12)
        .style("fill", "#fff").node()

    @selection.append("rect")
      .attr("height", 18)
      .attr("width", -> datum.name.trim().length * 10 )
      .attr("x", => (data.length * @options.bar_width) + 8 )
      .attr("y", => @options.y + 25 )
      .style "fill", datum.colour


    this


  remove: ->
    parent = @element.parentElement
    parent.removeChild @element


