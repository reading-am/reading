define [
  "app/views/base/model"
  "app/models/post"
  "app/models/comment"
  "text!app/views/providers/provider/template.mustache"
], (ModelView, Post, Comment, template) ->

  class ProviderView extends ModelView
    @parse_template template

    events:
      "click" : "run"

    run: ->
      @model.run()
