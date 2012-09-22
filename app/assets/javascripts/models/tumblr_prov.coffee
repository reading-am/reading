define [
  "app/init"
  "models/provider"
], (App, Provider) ->

  class TumblrProv extends Provider

  TumblrProv::login = (response, perms) ->
    super
      url: '/auth/loading/tumblr'
      width: 700
      height: 700,
      response

  App.Models.TumblrProv = TumblrProv
  return TumblrProv
