class @app.Slider extends @app.Delegator
  events:
    "mouseup": "onMouseUp"

  constructor: (element, options) ->
    super element, options
    @graph = options.graph

  onMouseUp: (event) ->
    container = event.target.parentElement
    container.querySelector("output").value = event.target.value

    # Update sunburst graph
    app.ciclo = event.target.value
    @graph.update()
