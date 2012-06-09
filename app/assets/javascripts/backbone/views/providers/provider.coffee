reading.define "app/views/providers/provider", [
  "backbone"
  "handlebars"
  "app/models/post"
  "app/models/comment"
], (Backbone, Handlebars, Post, Comment) ->

  class ProviderView extends Backbone.View
    template: Handlebars.compile "<a href=\"#\" class=\"r_share r_{{name}}\">{{name}}</a>"

    tagName: "li"

    events:
      "click" : "run"

    run: ->
      @model.run()

    render: ->
      @$el.html(@template(@model.toJSON()))
      return this
