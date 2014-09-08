define [
  "app/views/base/model"
  "app/models/oauth_app"
  "text!app/views/oauth_apps/oauth_app/styles.css"
  "text!app/views/oauth_apps/oauth_app/template.mustache"
], (ModelView, OauthApp, styles, template) ->

  class OauthAppView extends ModelView
    @assets
      styles: styles
      template: template
