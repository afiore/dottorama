class @app.Tooltip extends @app.Delegator
  constructor: (options = {}) ->

    @selection = d3.select("body")
      .append("div")
      .attr("class", "tooltip")

    @graph = options.grap
    super(@selection.node(), options)

  show: (d) ->
    text = d.human_name or d.name
    text += " ( #{d?.frequencies?[app.ciclo] })"
    area = d.depth == 1 && d or d?.parent
    d = area if d.depth == 1

    colour = d3.hsl @options.graph.colourScales.hue(area.name), 1, 0.5

    if d and text
      @selection.text(text)
        .style("visibility", "visible")
        .style("background", colour.toString())

    this

  hide: () ->
    @selection.style("visibility", "hidden")
    this

  move: (event) ->
    @selection.style("top",  (event.pageY - 10) + "px")
      .style("left", (event.pageX + 10) + "px")

    this

