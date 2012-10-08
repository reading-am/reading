define [
  "backbone"
], (Backbone) ->

  class ModelView extends Backbone.View
    tagName: "li"

    initialize: (options) ->
      @model.bind "change", @render, this
      @model.bind "destroy", @remove, this
      @model.bind "remove", @remove, this

    render: =>
      @$el.html(@template(@model.toJSON())) if @template?
      return this
