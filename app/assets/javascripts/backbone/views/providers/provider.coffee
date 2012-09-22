define [
  "backbone"
  "handlebars"
  "app/models/post"
  "app/models/comment"
  "text!app/templates/providers/provider.hbs"
], (Backbone, Handlebars, Post, Comment, template) ->

  class ProviderView extends Backbone.View
    template: Handlebars.compile template

    tagName: "li"

    events:
      "click" : "run"

    run: ->
      @model.run()

    render: ->
      @$el.html(@template(@model.toJSON()))
      return this
