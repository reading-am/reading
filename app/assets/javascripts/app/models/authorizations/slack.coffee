define [
  "app/init"
  "app/models/authorizations/authorization"
  "app/models/providers/slack"
], (App, Authorization, SlackProv) ->

  class SlackAuth extends Authorization
    type: "SlackAuth"
    provider: "slack"
    _login: SlackProv::login
    places: (params) ->
      # transform the return val
      if params.success?
        success = params.success
        params.success = (places) ->
          success ({text:place.name, value:place.guid} for place in places)

      super params

  App.Models.SlackAuth = SlackAuth
  return SlackAuth
