define [
  "backbone"
], (Backbone) ->

  class SelectorView extends Backbone.View

    events:
      "change select" : "changed"

    initialize: (options) ->
      @on_change = options.on_change
      @start_val = options.start_val
      @$("select").val @start_val

    changed: (e) ->
      @on_change @$(e.target).attr("value")

    value: ->
      @$("select").attr("value")

    json: ->
      j = {}
      j[@start_val] = true
      return j

    render: ->
      @$el.html(@template(@json()))
      return this
