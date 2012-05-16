define ["jquery","backbone","handlebars","app/models/post"], ($, Backbone, Handlebars, Post) ->

  class ProviderView extends Backbone.View
    template: Handlebars.compile "<a href=\"#\" class=\"r_share\">{{name}}</a>"

    events:
      "click" : "run"

    tagName: "li"

    run: ->
      @model.get("action")(@model.url Post::current)
      false

    render: ->
      $(@el).html(@template(@model.toJSON()))
      return this
