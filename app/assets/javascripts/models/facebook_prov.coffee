define [
  "app"
  "models/provider"
], (App, Provider) ->

  class App.Models.FacebookProv extends Provider

  App.Models.FacebookProv::login = (response, perms) ->
    super
      url: '/auth/loading/facebook'
      width: 981
      height: 600,
      response

  return App.Models.FacebookProv
