define [
  "app/views/base/model"
  "mustache"
  "app/models/post"
  "app/models/comment"
  "text!app/templates/providers/provider.mustache"
], (ModelView, Handlebars, Post, Comment, template) ->

  class ProviderView extends ModelView
    template: Handlebars.compile template

    events:
      "click" : "run"

    run: ->
      @model.run()
