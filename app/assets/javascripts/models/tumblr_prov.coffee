define [
  "app"
  "models/provider"
], (App, Provider) ->

  class App.Models.TumblrProv extends Provider

  App.Models.TumblrProv::login = (response, perms) ->
    super
      url: '/auth/loading/tumblr'
      width: 700
      height: 700,
      response

  return App.Models.TumblrProv
