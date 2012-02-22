getArea = (d) ->
    d = d.parent while d.parent and d.parent.name != 'Root'
    d

stash = (d) ->
  d.fill0 = d3.select(this).style("fill")
  d.x0 = d.x
  d.dx0 = d.dx

arcTween = (a) ->
  i = d3.interpolate( x: a.x0, dx: a.dx0, a)
  (t) ->
    b = i(t)
    a.x0 = b.x
    a.dx0 = b.dx
    arc(b)

sectorValue = (d) ->
  d?.frequencies?[app.ciclo] || 0

class @app.SunburstGraph extends @app.Delegator

  events:
    "path mouseover": "onMouseover",
    "path mouseout" : "onMouseout",
    "path click"    : "onClick",
    "path mousemove": "onMousemove"



  #
  # Refactor this, data should be passed in as an argument of 
  # the #render() method.
  #
  # 
  constructor: (@data, @element = "#chart", @options = {}) ->
    _.defaults(@options, width: 700, height:700)
    r = Math.min(@options.width, @options.height) / 2

    @vis = d3.select(@element).append("svg")
      .attr("width",  @options.width)
      .attr("height", @options.height)
      .append("g")
      .attr("transform", "translate(" + @options.width / 2 + "," + @options.height / 2 + ")")

    @partition = d3.layout.partition()
      .sort( (a, b) -> b?.frequencies?[app.ciclo] - a.frequencies[app.ciclo] || 1)
      .size([2 * Math.PI, r * r])
      .value(sectorValue)

    @arc = d3.svg.arc()
      .startAngle((d) -> d.x)
      .endAngle((d) -> d.x + d.dx)
      .innerRadius((d) -> Math.sqrt(d.y))
      .outerRadius((d) -> Math.sqrt(d.y + d.dy))

    # TODO: 
    # implement some sort of pub/sub so that
    # objects can bind and respond to each other events..
    #
    @tooltip = new app.Tooltip graph: this
    @barchartPanel = @options.barchartPanel

    this.setColourScales()
    super @element, @options

  render: ->

    @vis.data([@data]).selectAll("path")
      .data(@partition.nodes)
      .enter()
      .append("g")

    @vis.selectAll("g").append("path")
      .attr("display", (d) -> 
        if d.depth and d.depth < 3 then null else "none" 
      )
      .attr("d", @arc)
      .attr("fill-rule", "evenodd")
      .style("stroke", "#fff")
      .style("fill", (d) => 
        return unless d.depth > 0

        d = getArea(d)
        level = @colourScales.level(d.frequencies[app.ciclo])
        "hsl(0, 0%, #{level}%)"

      ).each(stash)

    this

  setColourScales: ->
    sectorNames  = (name for {name: name} in @data.children)
    sectorValues = (sectorValue child for child in @data.children).sort (a, b) -> b - a

    @colourScales = 
      hue: d3.scale.ordinal().domain(sectorNames).rangePoints([0, 359])
      level: d3.scale.ordinal().domain(sectorValues).rangeRoundBands([0, 100])

  update: ->
    this.setColourScales()

    @vis.selectAll("path")
      .data(@partition.value sectorValue)
      .transition()
      .duration(1000)
      .style("fill", (d) =>  
        d = getArea(d)
        level = @colourScales.level(sectorValue(d))
        "hsl(0, 0%, #{level}%)"

      ).attrTween("d", (a) => 
        i = d3.interpolate(x: a.x0, dx: a.dx0, a)
        (t) => 
          b = i(t)
          a.x0 = b.x
          a.dx0 = b.dx
          @arc(b)
      )

  onMouseover: (event, d) ->
    this._colouriseSector(d) unless d.active
    @tooltip.show(d)

  onMouseout: (event, d) ->
    this._downlightSector(d) unless d.active
    @tooltip.hide()

  onClick: (event, d) ->
    this._downlightAll()

    this._fetchRelatedSectors(d).then ((data) =>
      d1 = _.clone d
      d1.colour = d3.hsl(@colourScales.hue(d.parent.name), 1, 0.5).toString()
      @barchartPanel.clear().render d1, data

      null
    ), (error) -> throw error

  onMousemove: (event) ->
    @tooltip.move(event)


  # 
  # Highlights the current research sector
  #
  # If the user's mouse hovers a research area, hightlights also the area's child sectors.
  #
  # d - The d3 datum associated to the current event target element.
  #
  # Returns nothing.
  #
  #

  _colouriseSector: (d) ->
    area = getArea(d)
    d = area if d.depth == 1
    elementColour = d3.hsl @colourScales.hue(area.name), 1, 0.5

    @vis.selectAll("path")
      .filter( (dd)-> dd == d or dd.parent == d )
      .style("fill", elementColour.toString())

    this


  _downlightSector: (d) ->
    @vis.selectAll("path").filter((dd) -> dd == d or dd.parent == d ).style "fill", (dd) -> dd.fill0
    this

  _downlightAll: (d) -> 
    @vis.selectAll("path")
      .style("fill", (d) -> d.fill0)
      .each (d) -> d.active = false

    this

  #
  # Fetches a list of related research sectors
  #
  # Returns nothing.
  #
  _fetchRelatedSectors: (d) ->
    app.api.fetchOccurencies(d.name, app.ciclo).then (args) =>
      output = []

      [data, average] = args
      relevant = ([sector, count] for sector, count of data when count >= average)
      nodes    = (sector for [sector, count] in relevant)

      @vis.selectAll('path').filter((node) ->
        nodes.indexOf(node.name) > -1

      ).style("fill", (d) =>
        parent = getArea(d)
        colour = d3.hsl(@colourScales.hue(parent.name), 1, 0.5).toString()

        output.push colour: colour, name: d.name, frequencies: d.frequencies, co_occurencies: data[d.name]
        colour

      ).each (d) -> d.active = true

      output
