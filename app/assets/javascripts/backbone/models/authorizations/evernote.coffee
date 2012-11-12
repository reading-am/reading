define [
  "app/init"
  "app/models/authorizations/authorization"
  "app/models/providers/evernote"
], (App, Authorization, EvernoteProv) ->

  class EvernoteAuth extends Authorization
    provider: "evernote"
    _login: EvernoteProv::login
    places: (params) ->
      # transform the return val
      if params.success?
        success = params.success
        params.success = (places) ->
          success ({text:place.name, value:place.guid} for place in places)

      super params

  App.Models.EvernoteAuth = EvernoteAuth
  return EvernoteAuth
