define [
  "app"
  "models/provider"
], (App, Provider) ->

  class App.Models.InstapaperProv extends Provider

  App.Models.InstapaperProv::login = (response, perms) ->
    super
      url: '/auth/loading/instapaper'
      width: 430
      height: 360,
      response

  return App.Models.InstapaperProv
