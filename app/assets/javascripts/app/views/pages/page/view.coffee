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
      json.hostname = @model.parse_hostname()
      json.display_name =
        if json.hostname[..3] is "www."
          json.hostname[4..]
        else
          json.hostname

      domain = @model.parse_root_domain()

      if domain is "twitter.com" and json.embed
        delete json.title
        delete json.description
      else if json.title is json.url and json.description
        if json.description.length > 80
          json.title = "#{json.description[..80]}…"
        else
          json.title = json.description
          delete json.description

      if @model.posts.length
        json.url = @model.posts.first().get("wrapped_url")

      if domain not in PageView::safe_embed and @model.get("medium") in ["audio","video"]
        json.embed = false

      return json

  PageView::safe_embed = [
    "youtube.com"
    "vimeo.com"
    "soundcloud.com"
    "bandcamp.com"
    "kickstarter.com"
    ]

  return PageView
