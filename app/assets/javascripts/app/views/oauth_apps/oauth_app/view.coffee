define [
  "app/views/base/model"
  "text!app/views/oauth_apps/oauth_app/template.mustache"
], (ModelView, template) ->

  class OauthAppView extends ModelView
    @assets
      template: template
