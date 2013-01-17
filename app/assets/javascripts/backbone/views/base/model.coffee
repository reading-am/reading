define [
  "backbone"
], (Backbone) ->

  class ModelView extends Backbone.View
    tagName: "li"

    initialize: (options) ->
      @model.on "change", @render, this
      @model.on "destroy", @remove, this
      @model.on "remove", @remove, this

    render: =>
      @$el.html(@template(@model.toJSON(false))) if @template?
      return this
