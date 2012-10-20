define [
  "app/init"
  "models/provider"
], (App, Provider) ->

  class PocketProv extends Provider

  PocketProv::login = (response, perms) ->
    super
      url: '/auth/loading/pocket'
      width: 1024
      height: 568,
      response

  App.Models.PocketProv = PocketProv
  return PocketProv
