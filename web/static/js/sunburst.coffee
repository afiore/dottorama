
stash = (d) ->
  d.x0 = d.x
  d.dx0 = d.dx

init = () ->

  w = 960
  h = 700
  r = Math.min(w, h) / 2
  colourHue = null
  colourSaturation = null

  getArea = (d) ->
    d = d.parent while d.parent and d.parent.name != 'Root'
    d

  
  areaFilter = (d, node) ->
    node.name == d.name or node.parent?.name == d.name

  assignColourToArea = (d, colour, filter=areaFilter) ->
    vis.selectAll('path').filter((node) ->
      filter(d, node)
    ).style("fill", colour.toString())

  assignColour = (d) -> 
    d = getArea(d)
    s = colourSaturation(d.total)
    "hsl(0, 0%, #{s}%)"

  onMouseover = (d) ->
    area = getArea(d)
    d = area if d.depth == 1
    hue = colourHue(area.name)
    colour = d3.hsl(hue, 1, 0.5)
    assignColourToArea(d, colour)


  onMouseout = (d) ->
    d = getArea(d)
    colour = assignColour(d)
    assignColourToArea(d, colour)



  vis = d3.select("#chart").append("svg")
          .attr("width", w)
          .attr("height", h)
          .append("g")
          .attr("transform", "translate(" + w / 2 + "," + h / 2 + ")")

  partition = d3.layout.partition()
                .sort(null)
                .size([2 * Math.PI, r * r])
                .value((d) -> 1)

  arc = d3.svg.arc()
          .startAngle((d) -> d.x)
          .endAngle((d) -> d.x + d.dx)
          .innerRadius((d) -> Math.sqrt(d.y))
          .outerRadius((d) -> Math.sqrt(d.y + d.dy))

  
  d3.json "/distributions/19", (data) ->
    # define the colour hue scale for top 
    colourHue = d3.scale.ordinal().domain(data.map((d) -> d.name)).rangePoints([0, 259])
    colourSaturation = d3.scale.ordinal().domain(data.map((d) -> d.total)).rangeRoundBands([0, 100])


    path = vis.data([name: "Root", children: data ]).selectAll("path")
      .data(partition.nodes)
      .enter()
      .append("g")
      .append("title").text((d) -> "#{d.name} #{ '('+ d.total + ')' if d.total }" )

      vis.selectAll("g").append("path")
       .attr("display", (d) -> 
         if d.depth and d.depth < 3 then null else "none" 
       ) #hide inner ring
       .attr("d", arc)
       .attr("fill-rule", "evenodd")
       .style("stroke", "#fff")
       .style("fill", assignColour)
       .on("mouseover", onMouseover)
       .on("mouseout", onMouseout)



document.addEventListener "DOMContentLoaded", init

