define [
  "app/init"
  "app/models/providers/provider"
], (App, Provider) ->

  class InstapaperProv extends Provider
    type: "InstapaperProv"

  InstapaperProv::login = (response, perms) ->
    super
      url: '/users/auth/loading/instapaper'
      width: 360
      height: 250,
      response

  App.Models.InstapaperProv = InstapaperProv
  return InstapaperProv
