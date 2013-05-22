define [
  "app/views/base/model"
  "app/models/post"
  "app/models/comment"
  "text!app/views/providers/provider/template.mustache"
], (ModelView, Post, Comment, template) ->

  class ProviderView extends ModelView
    @assets
      template: template

    events:
      "click" : "run"

    run: ->
      @model.run()

    json: ->
      json = super()
      json.className = json.name.toLowerCase().replace(/[^a-zA-Z0-9]/g, '')
      json
