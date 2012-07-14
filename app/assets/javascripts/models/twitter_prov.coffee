reading.define [
  "app/init"
  "models/provider"
], (App, Provider) ->

  class TwitterProv extends Provider

  TwitterProv::login = (response, perms) ->
    super
      url: '/auth/loading/twitter'
      width: 700
      height: 700,
      response

  App.Models.TwitterProv = TwitterProv
  return App.Models.TwitterProv
