define [
  "app/init"
  "app/models/authorizations/authorization"
  "app/models/providers/slack"
], (App, Authorization, SlackProv) ->

  class SlackAuth extends Authorization
    type: "SlackAuth"
    provider: "slack"
    default_perms: ["identify", "channels:read", "chat:write:bot"]
    _login: SlackProv::login

    initialize: (options) ->
      super

      if @info?
        @name = "#{@info.team} / #{@info.user}"

    places: (params) ->
      # transform the return val
      if params.success?
        success = params.success
        params.success = (places) ->
          success ({text: place.name, value: place.id} for place in places)

      super params

  App.Models.SlackAuth = SlackAuth
  return SlackAuth
