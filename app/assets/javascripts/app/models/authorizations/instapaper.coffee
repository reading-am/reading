define [
  "app/init"
  "app/models/authorizations/authorization"
  "app/models/providers/instapaper"
], (App, Authorization, InstapaperProv) ->

  class InstapaperAuth extends Authorization
    type: "InstapaperAuth"
    provider: "instapaper"
    _login: InstapaperProv::login

  App.Models.InstapaperAuth = InstapaperAuth
  return InstapaperAuth
