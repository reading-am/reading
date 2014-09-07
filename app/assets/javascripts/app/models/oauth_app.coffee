define [
  "backbone"
  "app/init"
], (Backbone, App) ->

  class OauthApp extends Backbone.Model
    type: "OauthApp"

  App.Models.OauthApp = OauthApp
  return OauthApp
