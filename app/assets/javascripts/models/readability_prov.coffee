define [
  "app"
  "models/provider"
], (App, Provider) ->

  class App.Models.ReadabilityProv extends Provider

  App.Models.ReadabilityProv::login = (response, perms) ->
    super
      url: '/auth/loading/readability'
      width: 600
      height: 450,
      response

  return App.Models.ReadabilityProv
