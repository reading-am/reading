define [
  "backbone"
  "app/init"
], (Backbone, App) ->

  class OauthAccessToken extends Backbone.Model
    type: "OauthAccessToken"
    urlName: "oauth_access_token"
    idAttribute: "token"

  App.Models.OauthAccessToken = OauthAccessToken
  return OauthAccessToken
