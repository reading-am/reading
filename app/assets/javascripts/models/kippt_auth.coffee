reading.define [
  "app"
  "models/authorization"
  "models/kippt_prov"
], (App, Authorization, KipptProv) ->

  class KipptAuth extends Authorization
    provider: "kippt"
    _login: KipptProv::login

  App.Models.KipptAuth = KipptAuth
  return KipptAuth
