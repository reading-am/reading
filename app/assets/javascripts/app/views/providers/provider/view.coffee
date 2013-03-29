define [
  "app/views/base/model"
  "mustache"
  "app/models/post"
  "app/models/comment"
  "text!app/views/providers/provider/template.mustache"
], (ModelView, Mustache, Post, Comment, template) ->

  class ProviderView extends ModelView
    template: Mustache.compile template

    events:
      "click" : "run"

    run: ->
      @model.run()
