define [
  "backbone"
  "app/init"
  "app/models/oauth_access_token"
], (Backbone, App, OauthAccessToken) ->

  class App.Collections.OauthAccessTokens extends Backbone.Collection
    type: "OauthAccessTokens"
    model: OauthAccessToken
