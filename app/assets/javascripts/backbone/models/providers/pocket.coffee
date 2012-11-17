define [
  "app/init"
  "app/models/providers/provider"
], (App, Provider) ->

  class PocketProv extends Provider
    type: "PocketProv"

  PocketProv::login = (response, perms) ->
    super
      url: '/auth/loading/pocket'
      width: 1024
      height: 568,
      response

  App.Models.PocketProv = PocketProv
  return PocketProv
