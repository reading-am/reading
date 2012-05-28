define [
  "backbone"
  "handlebars"
  "app/models/post"
], (Backbone, Handlebars, Post) ->

  class ProviderView extends Backbone.View
    template: Handlebars.compile "<a href=\"#\" class=\"r_share r_{{name}}\">{{name}}</a>"

    events:
      "click" : "run"

    tagName: "li"

    run: ->
      @model.get("action")(@model.url Post::current)

    render: ->
      @$el.html(@template(@model.toJSON()))
      return this
