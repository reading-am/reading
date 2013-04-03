define [
  "backbone"
  "app/init"
  "text!app/views/uris/uri/template.mustache"
], (Backbone, App, template) ->

  class URIView extends Backbone.View
    @parse_template template

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
