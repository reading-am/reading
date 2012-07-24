reading.define [
  "app"
  "models/authorization"
  "models/tssignals_prov"
], (App, Authorization, TssignalsProv) ->

  class TssignalsAuth extends Authorization
    provider: "tssignals"
    _login: TssignalsProv::login

  App.Models.TssignalsAuth = TssignalsAuth
  return TssignalsAuth
