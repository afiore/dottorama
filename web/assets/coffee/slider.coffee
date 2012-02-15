eventHandlers =
  mouseup: 
    showOutput: (event) ->
      @container.querySelector("output").value = event.target.value

    updateGraph: (event) ->
      app.ciclo = event.target.value
      @graph.update()




class @app.Slider
  constructor: (@selector, @graph) ->
    @element = document.querySelector(@selector)
    @container = @element.parentNode
    @element.addEventListener "mouseup", (event) => app.utils.applyAll _.values(eventHandlers.mouseup), [event], this


@app.__defineGetter__("ciclo", -> app._ciclo or 19 )
