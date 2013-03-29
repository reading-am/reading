define [
  "app/init"
  "app/models/authorizations/authorization"
  "app/models/providers/flattr"
], (App, Authorization, FlattrProv) ->

  class FlattrAuth extends Authorization
    type: "FlattrAuth"
    provider: "flattr"
    _login: FlattrProv::login

  App.Models.FlattrAuth = FlattrAuth
  return FlattrAuth
