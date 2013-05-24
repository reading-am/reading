define [
  "app/models/user_with_current"
  "app/views/base/model"
  "text!app/views/pages/page/template.mustache"
  "text!app/views/pages/page/styles.css"
  "app/models/page" # this has to be loaded here because it's not referenced anywhere else
], (User, ModelView, template, styles) ->

  class PageView extends ModelView
    @assets
      styles: styles
      template: template

    json: ->
      json = super()

      if @model.posts.length
        json.url = @model.posts.first().get("wrapped_url")

      if !User::current.access("media_feed")
        json.embed = false

      return json
