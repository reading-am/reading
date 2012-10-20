define [
  "app/init"
  "models/authorization"
  "models/pocket_prov"
], (App, Authorization, PocketProv) ->

  class PocketAuth extends Authorization
    provider: "pocket"
    _login: PocketProv::login

  App.Models.PocketAuth = PocketAuth
  return PocketAuth
