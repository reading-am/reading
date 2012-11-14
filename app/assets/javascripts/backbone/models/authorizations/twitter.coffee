define [
  "app/init"
  "app/models/authorizations/authorization"
  "app/models/providers/twitter"
], (App, Authorization, TwitterProv) ->

  class TwitterAuth extends Authorization
    type: "TwitterAuth"
    provider: "twitter"
    _login: TwitterProv::login

  App.Models.TwitterAuth = TwitterAuth
  return TwitterAuth
