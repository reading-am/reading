define [
  "app"
  "models/provider"
], (App, Provider) ->

  class KipptProv extends Provider

  KipptProv::login = (response, perms) ->
    super
      url: '/auth/loading/kippt'
      width: 430
      height: 360,
      response

  App.Models.KipptProv = KipptProv
  return App.Models.KipptProv
