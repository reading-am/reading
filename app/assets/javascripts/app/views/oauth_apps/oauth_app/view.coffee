define [
  "backbone"
  "text!app/views/oauth_apps/oauth_app/template.mustache"
], (Backbone, template) ->

  class OauthAppView extends Backbone.View
    @assets
      template: template
