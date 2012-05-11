ø.Views.Providers ||= {}

class ø.Views.Providers.ProviderView extends ø.Backbone.View
  template: Handlebars.compile "<a href=\"#\" class=\"r_share\">{{name}}</a>"

  events:
    "click" : "run"

  tagName: "li"

  run: ->
    @model.get("action")(@model.url ø.Models.Post::current)
    false

  render: ->
    ø.$(@el).html(@template(@model.toJSON()))
    return this
