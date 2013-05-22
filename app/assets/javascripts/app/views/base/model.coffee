define [
  "backbone"
], (Backbone) ->

  class ModelView extends Backbone.View
    tagName: "li"

    initialize: (options) ->
      @model.on "change", @render, this
      @model.on "destroy", @remove, this
      @model.on "remove", @remove, this

    json: ->
      @model.toJSON()

    render: =>
      @$el.html(@template(@json())) if @template?
      return this
