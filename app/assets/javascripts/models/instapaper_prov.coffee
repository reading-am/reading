define [
  "app"
  "models/provider"
], (App, Provider) ->

  class InstapaperProv extends Provider

  InstapaperProv::login = (response, perms) ->
    super
      url: '/auth/loading/instapaper'
      width: 430
      height: 360,
      response

  App.Models.InstapaperProv = InstapaperProv
  return InstapaperProv
