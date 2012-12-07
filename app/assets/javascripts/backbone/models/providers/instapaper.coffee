define [
  "app/init"
  "app/models/providers/provider"
], (App, Provider) ->

  class InstapaperProv extends Provider
    type: "InstapaperProv"

  InstapaperProv::login = (response, perms) ->
    super
      url: '/users/auth/loading/instapaper'
      width: 430
      height: 360,
      response

  App.Models.InstapaperProv = InstapaperProv
  return InstapaperProv
