tick = null

getArea = (d) ->
    d = d.parent while d.parent and d.parent.name != 'Root'
    d

stash = (d) ->
  d.fill0 = d3.select(this).style("fill")


onMouseout = (element, d, i) ->
  d = getArea(d)
  @vis.selectAll("path").style("fill", (d) -> d.fill0)
  clearTimeout(tick)

onMouseover = (element, d, i) ->
  area = getArea(d)
  d = area if d.depth == 1

  # Highlight the current research sector 
  elementColour = d3.hsl @colourScales.hue(area.name), 1, 0.5
  d3.select(element).style("fill", elementColour.toString())

  tick = setTimeout =>
    # fetch a list of related research sectors
    collection = if d.parent.depth == 0 then "area" else "settore"

    app.api.fetchOccurencies(collection, d.name, 19)
      .then (data) => 

        data = data[0.. data.length / 3]
        nodes = data.map (item) -> item[0]

        @vis.selectAll 'path'.filter (node) ->
          nodes.indexOf(node.name) > -1

        .style "fill", (d) =>
          parent = getArea(d)
          colour = d3.hsl(@colourScales.hue(parent.name), 1, 0.5)
          colour.toString()


  , 1000


bindEvents = () ->
  runCurried = (func, element, d, i) =>
    func.call(this, element, d, i)

  @vis.selectAll("path")
    .on("mouseover", (d, i) -> runCurried onMouseover, this, d, i)
    .on("mouseout",  (d, i) -> runCurried onMouseout, this,  d, i)


class @app.SunburstGraph
  constructor: (data, @selector = "#chart", @options = {}) ->
    _.defaults(@options, width: 960, height:700)

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
      .append("title").text((d) -> "#{d.name} #{ '('+ d.total + ')' if d.total }" )

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

