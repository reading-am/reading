define [
  "app/init"
  "app/models/providers/provider"
], (App, Provider) ->

  class KipptProv extends Provider
    type: "KipptProv"

  KipptProv::login = (response, perms) ->
    super
      url: '/users/auth/loading/kippt'
      width: 360
      height: 250,
      response

  App.Models.KipptProv = KipptProv
  return App.Models.KipptProv
