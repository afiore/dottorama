height = null

getFrequencies = (datum) -> 
  value for cycle, value of datum.frequencies

class @app.Barchart extends @app.Delegator
  # Public:
  #
  # Initialises a barchart displaying sector frequencies per cycle.
  #
  # element - A selector identifying the container element within which the histogram should be rendered.
  # options - An option hash, accepted keys are:
  #   height:    Pixel height of the barchart.
  #   bar_width: Pixel width of each bar.
  #   maxValue:  The maximum sector frequency value in the entire dataset.
  #
  # Returns nothing
  #
  #
  constructor: (element, options = {}) ->
    phdCycles = 7

    _.defaults(options, height: 30, bar_width: 10)

    height = d3.scale.linear().domain([0, parseInt(options.maxValue)]).range [0, options.height]

    @selection = d3.select(element).append("svg")
      .attr("width", options.bar_width * phdCycles)
      .attr("height", options.height)

    super d3.select(element).node(), options

  # public:
  #
  # Renders the barchart
  #
  # data - a d3 datum
  # 
  # Returns itself
  #

  render: (event, datum) ->
    if @initialised then this.refresh datum else this._initialize datum
    this

  refresh: (datum) ->
    @selection.selectAll("rect")
      .data(getFrequencies datum)
      .transition()
      .duration(1000)
      .attr("height", height)
    this

  _initialize: (datum) ->
    @selection.selectAll("rect")
      .data(getFrequencies datum )
      .enter().append("rect")
      .attr("x", (d, i) => i * @options.bar_width )
      .attr("y", (d, i) => @options.height - height(d))
      .attr("width", @options.bar_width)
      .attr("height", height)

    @initialised = true
    this
