define [
  "backbone"
  "app/init"
], (Backbone, App) ->

  class OauthAccessToken extends Backbone.Model
    type: "OauthAccessToken"

  App.Models.OauthAccessToken = OauthAccessToken
  return OauthAccessToken
