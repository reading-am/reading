define [
  "backbone"
  "app/init"
  "app/models/oauth_app"
], (Backbone, App, OauthApp) ->

  class App.Collections.OauthApps extends Backbone.Collection
    type: "OauthApps"
    model: OauthApp
