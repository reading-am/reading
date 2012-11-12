define [
  "app/init"
  "app/models/authorizations/authorization"
  "app/models/providers/readability"
], (App, Authorization, ReadabilityProv) ->

  class ReadabilityAuth extends Authorization
    provider: "readability"
    _login: ReadabilityProv::login

  App.Models.ReadabilityAuth = ReadabilityAuth
  return ReadabilityAuth
