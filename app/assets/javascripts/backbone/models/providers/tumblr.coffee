define [
  "app/init"
  "app/models/providers/provider"
], (App, Provider) ->

  class TumblrProv extends Provider
    type: "TumblrProv"

  TumblrProv::login = (response, perms) ->
    super
      url: '/users/auth/loading/tumblr'
      width: 700
      height: 700,
      response

  App.Models.TumblrProv = TumblrProv
  return TumblrProv
