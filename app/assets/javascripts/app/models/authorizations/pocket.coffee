define [
  "app/init"
  "app/models/authorizations/authorization"
  "app/models/providers/pocket"
], (App, Authorization, PocketProv) ->

  class PocketAuth extends Authorization
    type: "PocketAuth"
    provider: "pocket"
    _login: PocketProv::login

  App.Models.PocketAuth = PocketAuth
  return PocketAuth
