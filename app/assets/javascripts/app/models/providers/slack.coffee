define [
  "app/init"
  "app/models/providers/provider"
], (App, Provider) ->

  class SlackProv extends Provider
    type: "SlackProv"

  SlackProv::login = (response, perms) ->
    super
      url: '/users/auth/loading/slack'
      width: 600
      height: 670,
      response

  App.Models.SlackProv = SlackProv
  return SlackProv
