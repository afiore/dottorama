eventHandlers =
  change: 
    showOutput: (event) ->
      @container.querySelector("output").value = event.target.value

    updateGraph: (event) ->
      ciclo = event.target.value

      app.api.fetchDistributions(ciclo).then (data) =>
        @graph.reset(data).render()


class @app.Slider
  constructor: (@selector, @graph) ->
    @element = document.querySelector(@selector)
    @container = @element.parentNode

    @element.addEventListener "mouseup", (event) => app.utils.applyAll _.values(eventHandlers.change), [event], this

