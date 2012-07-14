reading.define [
  "app/init"
  "models/authorization"
  "models/instapaper_prov"
], (App, Authorization, InstapaperProv) ->

  class InstapaperAuth extends Authorization
    provider: "instapaper"
    _login: InstapaperProv::login

  App.Models.InstapaperAuth = InstapaperAuth
  return InstapaperAuth
