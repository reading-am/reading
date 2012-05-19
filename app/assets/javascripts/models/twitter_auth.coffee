define [
  "app"
  "models/authorization"
  "models/twitter_prov"
], (App, Authorization, TwitterProv) ->

  class TwitterAuth extends Authorization
    provider: "twitter"
    _login: TwitterProv::login

  App.Models.TwitterAuth = TwitterAuth
  return TwitterAuth
