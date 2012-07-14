reading.define [
  "app/init"
  "models/authorization"
  "models/readability_prov"
], (App, Authorization, ReadabilityProv) ->

  class ReadabilityAuth extends Authorization
    provider: "readability"
    _login: ReadabilityProv::login

  App.Models.ReadabilityAuth = ReadabilityAuth
  return ReadabilityAuth
