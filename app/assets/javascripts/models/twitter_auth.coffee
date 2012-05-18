define [
  "app"
  "models/authorization"
], (App, Authorization) ->

  class App.Models.TwitterAuth extends Authorization
    provider: "twitter"
    _login: App.Models.TwitterProv::login
