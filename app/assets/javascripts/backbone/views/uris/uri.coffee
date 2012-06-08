reading.define [
  "backbone"
  "app"
], (Backbone, App) ->

  class URIView extends Backbone.View
    tagName: "a"
    className: "r_url"

    initialize: (options) ->
      @model.bind "change", @render, this
      @model.bind "destroy", @remove, this

    attributes: ->
      href: @model.get("string")

    render: ->
      @$el.html(@template(@model.toJSON()))
      return this

  URIView::factory = (model) ->
    new App.Views.URIs[model.type] model: model

  App.Views.URIs = {}
  App.Views.URI = URIView
  return URIView
