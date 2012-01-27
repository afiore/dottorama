(function () {


  function visualiseData (event) {
    var allCicli = function () {
          return [19, 20, 21, 22, 23, 24, 25, 26];
        },
        currentAttribute = "area",
        r = 760,
        format = d3.format("02d"),
        fill   = d3.scale.category20c(),
        bubble = d3.layout.pack()
                   .sort(null)
                   .size([r, r]),

        vis = d3.select("div#chart").append("svg")
                   .attr("width", r)
                   .attr("height", r)
                   .attr("class", "bubble"),

        formatData = function (json) {
          var frequencies = json.map(function (item) {  return { label: item[0], value: parseInt(item[1], 10)}; });
          return bubble.nodes({children: frequencies}).filter(function (d) { return !d.children; });
        },

        makeGraph = function (json) {
          var graphData = formatData(json);

          var node = vis.selectAll("g.node")
              .data(graphData, function (d) { return d.label; });

          node.enter().append("g")
                  .attr("class", "node")
                  .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; });

          node.append("title")
              .text(function(d) { return d.label + ": " + format(d.value); });

          node.append("circle")
              .attr("r", function(d) { return d.r; })
              .style("fill", function(d) { return fill(d.label); });

          node.append("text")
              .attr("text-anchor", "middle")
              .attr("dy", ".3em")
              .text(function(d) { return d.label.substring(0, d.r / 3); });

          //node.exit().remove();
        },

        redraw = function (json) {
          var graphData = formatData(json);

          vis.selectAll("circle")
             .data(graphData, function (d) { return d.label; })
             .transition()
                .duration(1000)
                .attr("r", function (d) { return d.r; });

    };


    var cicles = allCicli();
    var interval = setInterval(function () {
      var next = cicles.shift();

      if (next) {
        d3.json(["/distributions", currentAttribute, next].join("/") , redraw);
      } else {
        clearInterval(interval);
      }
    }, 3000);

    d3.json("/distributions/"+ currentAttribute  +"/19", makeGraph);


    document.querySelector("select").addEventListener("change", function (event) {
      cicles = allCicli();
      currentAttribute = event.target.value;
      vis.selectAll("g.node").data([]).exit().remove();
      d3.json("/distributions/"+ currentAttribute  +"/19", makeGraph);
    });

  };

  document.addEventListener("DOMContentLoaded", visualiseData)


}).call(window);

