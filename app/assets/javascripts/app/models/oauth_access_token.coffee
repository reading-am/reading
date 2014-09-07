define [
  "backbone"
  "app/init"
], (Backbone, App) ->

  class OauthAccessToken extends Backbone.Model
    type: "OauthAccessToken"
    idAttribute: "token"

  App.Models.OauthAccessToken = OauthAccessToken
  return OauthAccessToken
