getDatum = (element) ->
  element.__data__

class @app.Delegator
  constructor: (@element, @options={}) ->
    @element = document.querySelector(@element) if typeof @element == "string"
    this.bindEvents()

  bindEvents: ->
    return unless @events

    for sel, functionName of @events
      [selector..., event] = sel.split " "
      this.addEvent selector.join(' '), event, functionName

  addEvent: (selector, eventName, functionName) ->
    closure = => this[functionName].apply(this, arguments)

    @element.addEventListener eventName, (event) =>
      selection = if selector then @element.querySelectorAll(selector) else [@element]
      closure event, getDatum(event.target) if _.include selection, event.target



