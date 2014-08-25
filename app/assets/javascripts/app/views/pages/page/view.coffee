define [
  "jquery"
  "app/models/user_with_current"
  "app/views/base/model"
  "text!app/views/pages/page/template.mustache"
  "text!app/views/pages/page/styles.css"
  "app/models/page" # this has to be loaded here because it's not referenced anywhere else
], ($, User, ModelView, template, styles) ->

  class PageView extends ModelView
    @assets
      styles: styles
      template: template

    json: ->
      json = super()

      if @model.posts.length
        json.url = @model.posts.first().get("wrapped_url")

      hostname = $("<a>", href: @model.get("url"))[0].hostname
      hostname = hostname.split(".")[-2..].join(".")
      if hostname not in PageView::safe_embed and @model.get("medium") in ["audio","video"]
        json.embed = false
      else if json.embed
        json.embed.replace "http://", "https://"

      return json

  PageView::safe_embed = [
    "youtube.com"
    "vimeo.com"
    "soundcloud.com"
    "bandcamp.com"
    ]

  return PageView
