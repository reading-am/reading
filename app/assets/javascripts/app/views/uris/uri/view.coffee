define [
  "underscore"
  "jquery"
  "backbone"
  "app/init"
  "text!app/views/uris/uri/template.mustache"
  "text!app/views/uris/uri/styles.css"
], (_, $, Backbone, App, template, css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class URIView extends Backbone.View
    @parse_template template

    initialize: (options) ->
      load_css()
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
