define [
  "backbone"
  "app/init"
  "text!app/views/uris/uri/template.mustache"
  "text!app/views/uris/uri/styles.css"
], (Backbone, App, template, styles) ->

  class URIView extends Backbone.View
    @assets
      styles: styles
      template: template

    initialize: (options) ->
      @model.bind "change", @render, this
      @model.bind "destroy", @remove, this
      super options

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
