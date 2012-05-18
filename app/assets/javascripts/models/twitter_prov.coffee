define [
  "app"
  "models/provider"
], (App, Provider) ->

  class App.Models.TwitterProv extends Provider

  App.Models.TwitterProv::login = (response, perms) ->
    super
      url: '/auth/loading/twitter'
      width: 700
      height: 700,
      response

  return App.Models.TwitterProv
