define [
  "app/init"
  "models/authorization"
  "models/evernote_prov"
], (App, Authorization, EvernoteProv) ->

  class EvernoteAuth extends Authorization
    provider: "evernote"
    _login: EvernoteProv::login

  App.Models.EvernoteAuth = EvernoteAuth
  return EvernoteAuth
