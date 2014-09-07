define [
  "app/views/base/model"
  "text!app/views/oauth_apps/oauth_app/styles.css"
  "text!app/views/oauth_apps/oauth_app/template.mustache"
], (ModelView, styles, template) ->

  class OauthAppView extends ModelView
    @assets
      styles: styles
      template: template

    json: ->
      json = super
      json.icon_thumb = "https://s3.amazonaws.com/media.development.reading.am/oauth_apps/icons/default/original.png"
      console.log json
      json
