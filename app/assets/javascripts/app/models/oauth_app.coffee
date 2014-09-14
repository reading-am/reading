define [
  "backbone"
  "app/init"
], (Backbone, App) ->

  class OauthApp extends Backbone.Model
    type: "OauthApp"
    urlName: "oauth_application"
    idAttribute: "consumer_key"

  App.Models.OauthApp = OauthApp
  return OauthApp
