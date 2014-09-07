define [
  "app/views/base/model"
  "text!app/views/oauth_apps/oauth_app/styles.css"
  "text!app/views/oauth_apps/oauth_app/template.mustache"
], (ModelView, styles, template) ->

  class OauthAppView extends ModelView
    @assets
      styles: styles
      template: template
