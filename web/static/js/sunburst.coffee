
stash = (d) ->
  d.x0 = d.x
  d.dx0 = d.dx

init = () ->

  w = 960
  h = 700
  r = Math.min(w, h) / 2
  color = d3.scale.category20c()

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

  
  d3.json "/distributions/19", (json) ->
    console.info(json)

    path = vis.data([name: "Root", children: json ]).selectAll("path")
      .data(partition.nodes)
      .enter()
      .append("g")
      .append("title").text((d) -> d.name )

      vis.selectAll("g").append("path")
       .attr("display", (d) -> if d.depth then null else "none" ) #hide inner ring
       .attr("d", arc)
       .attr("fill-rule", "evenodd")
       .style("stroke", "#fff")
       .style("fill", (d) ->  color(( if d.children then d else d.parent).name))
       .each(stash)


document.addEventListener "DOMContentLoaded", init

