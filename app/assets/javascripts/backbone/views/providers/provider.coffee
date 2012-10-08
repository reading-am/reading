define [
  "app/views/base/model"
  "handlebars"
  "app/models/post"
  "app/models/comment"
  "text!app/templates/providers/provider.hbs"
], (ModelView, Handlebars, Post, Comment, template) ->

  class ProviderView extends ModelView
    template: Handlebars.compile template

    events:
      "click" : "run"

    run: ->
      @model.run()
