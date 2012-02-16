

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



# 
# id for the delayed call to app.api.fetchOccurencies, used to display related sectors 
# when the user mouse hovers on a sector for more than 1 second.
#
#
tick = null

class @app.SunburstGraph extends @app.Delegator

  events:
    "path mouseover": "onMouseover",
    "path mouseout" : "onMouseout",
    "path click"    : "onClick",
    "path mousemove": "onMousemove"


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

    @tooltip = d3.select("body")
      .append("div")
      .attr("class", "tooltip")

    this.setColourScales()
    super @element

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
    this._displayTooltip(event, d)._colouriseSector(d)

  onMouseout: (event, d) ->
    this._hideTooltip(d)._downlightSector(d)._clearTimeout(event)

  onClick: (event, d) ->
    this._fetchRelatedSectors(d)

  onMousemove: (event) ->
    @tooltip
      .style("top",  (event.pageY - 10) + "px")
      .style("left", (event.pageX + 10) + "px")

  _displayTooltip: (event, d) ->
    text = d.human_name or d.name
    text += " ( #{d?.frequencies?[app.ciclo] })"

    area = getArea(d)
    d = area if d.depth == 1
    colour = d3.hsl @colourScales.hue(area.name), 1, 0.5

    if d and text
      @tooltip.text(text)
        .style("visibility", "visible")
        .style("background", colour.toString())

    this

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

  _hideTooltip: (d) ->
    @tooltip.style("visibility", "hidden")
    this

  _downlightSector: (d) ->
    d = getArea(d)
    @vis.selectAll("path").style("fill", (d) -> d.fill0)
    this

  _clearTimeout: ->
    clearTimeout(tick)
    this

  #
  # Fetches a list of related research sectors
  #
  # Returns nothing.
  #
  _fetchRelatedSectors: (d) ->
    tick = setTimeout =>
      app.api.fetchOccurencies(d.name, app.ciclo).then (args) =>

        [data, average] = args

        relevant = ([sector, count] for sector, count of data when count >= average)
        nodes    = (sector for [sector, count] in relevant)

        @vis.selectAll('path').filter((node) ->

          nodes.indexOf(node.name) > -1
        ).style("fill", (d) =>
          parent = getArea(d)
          colour = d3.hsl(@colourScales.hue(parent.name), 1, 0.5)
          colour.toString()
        )

    , 1000
    this

