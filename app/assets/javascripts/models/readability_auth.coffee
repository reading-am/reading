define [
  "app"
  "models/authorization"
], (App, Authorization) ->

  class App.Models.ReadabilityAuth extends Authorization
    provider: "readability"
    _login: App.Models.ReadabilityProv::login
