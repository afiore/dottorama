

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


# 
# id for the delayed call to app.api.fetchOccurencies, used to display related sectors 
# when the user mouse hovers on a sector for more than 1 second.
#
#
tick = null

eventHandlers = 
  mouseover:

    displayTooltip: (d, element) ->
      text = d.human_name or d.name
      area = getArea(d)
      d = area if d.depth == 1
      colour = d3.hsl @colourScales.hue(area.name), 1, 0.5

      if d and text
        @tooltip.text(text)
          .style("visibility", "visible")
          .style("background", colour.toString())

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

    colouriseSector: (d) ->
      area = getArea(d)
      d = area if d.depth == 1
      elementColour = d3.hsl @colourScales.hue(area.name), 1, 0.5

      @vis.selectAll("path")
        .filter( (dd)-> dd == d or dd.parent == d )
        .style("fill", elementColour.toString())

    #
    # Fetches a list of related research sectors
    #
    # d - The d3 datum associated to the current event target element.
    #
    # Returns nothing.
    #
    fetchRelatedSectors: (d) ->
      tick = setTimeout =>
        collection = if d.parent.depth == 0 then "area" else "settore"

        app.api.fetchOccurencies(collection, d.name, 19)
          .then (data) => 

            data = data[0.. data.length / 3]
            nodes = data.map (item) -> item[0]

            @vis.selectAll('path').filter((node) ->
              nodes.indexOf(node.name) > -1
            ).style("fill", (d) =>
              parent = getArea(d)
              colour = d3.hsl(@colourScales.hue(parent.name), 1, 0.5)
              colour.toString()
            )
      , 1000

  mouseout:
    hideTooltip: (d) ->
       @tooltip.style("visibility", "hidden")

    downlightSector: (d) ->
      d = getArea(d)
      @vis.selectAll("path").style("fill", (d) -> d.fill0)
    clearTimeout: ->
      clearTimeout(tick)

  mousemove:
    moveTooltip: ->
      @tooltip
        .style("top",  (d3.event.pageY - 10) + "px")
        .style("left", (d3.event.pageX + 10) + "px")

areaName = (d) ->
  aree = app.AREE
  area = switch d?.depth
    when 3 then null
    when 2 then  _.detect(aree[d.parent.name].settori, (settore) -> settore.id == d.name )
    when 1 then aree[d.name]
    else d

  area and area.name or "n/a"



bindEvents = () ->
  @vis.selectAll("path")
    .on("mouseover", (d, i) => app.utils.applyAll  _.values(eventHandlers.mouseover), [d, i], this)
    .on("mouseout",  (d, i) => app.utils.applyAll  _.values(eventHandlers.mouseout), [d, i], this)
    .on("mousemove", (d, i) => eventHandlers.mousemove.moveTooltip.call this)


class @app.SunburstGraph
  constructor: (data, @selector = "#chart", @options = {}) ->
    _.defaults(@options, width: 700, height:700)

    this.setData(data)

    r = Math.min(@options.width, @options.height) / 2

    @vis = d3.select(@selector).append("svg")
      .attr("width",  @options.width)
      .attr("height", @options.height)
      .append("g")
      .attr("transform", "translate(" + @options.width / 2 + "," + @options.height / 2 + ")")

    @partition = d3.layout.partition()
      .sort(null)
      .size([2 * Math.PI, r * r])
      .value((d) -> 1)

    @arc = d3.svg.arc()
      .startAngle((d) -> d.x)
      .endAngle((d) -> d.x + d.dx)
      .innerRadius((d) -> Math.sqrt(d.y))
      .outerRadius((d) -> Math.sqrt(d.y + d.dy))

    @tooltip = d3.select("body")
      .append("div")
      .attr("class", "tooltip")


  setData: (@data) ->
    sectorNames  = _.map(@data.children, (item) -> item.name)
    sectorValues = _.map(@data.children, (item) -> item.total)

    @colourScales = 
      hue: d3.scale.ordinal().domain(sectorNames).rangePoints([0, 359])
      level: d3.scale.ordinal().domain(sectorValues).rangeRoundBands([0, 100])
    this


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
        d = getArea(d)
        level = @colourScales.level(d.total)
        "hsl(0, 0%, #{level}%)"

      ).each(stash)


    bindEvents.call(this)
    this

  reset: ( data = null )-> 
    @vis.selectAll("g").data([]).exit().remove()
    this.setData data
    this

