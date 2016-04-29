define [
  "app/init"
  "app/models/authorizations/authorization"
  "app/models/providers/slack"
], (App, Authorization, SlackProv) ->

  class SlackAuth extends Authorization
    type: "SlackAuth"
    provider: "slack"
    _login: SlackProv::login

    initialize: (options) ->
      super
      @name = "#{options.info.team.name} - #{options.info.user.name}"

    places: (params) ->
      # transform the return val
      if params.success?
        success = params.success
        params.success = (places) ->
          success ({text: place.name, value: place.id} for place in places)

      super params

  App.Models.SlackAuth = SlackAuth
  return SlackAuth
