define [
  "app"
  "models/authorization"
], (App, Authorization) ->

  class App.Models.InstapaperAuth extends Authorization
    provider: "instapaper"
    _login: App.Models.InstapaperProv::login
