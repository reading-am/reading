define [
  "app/init"
  "app/models/providers/provider"
], (App, Provider) ->

  class TwitterProv extends Provider
    type: "TwitterProv"

  TwitterProv::login = (response, perms) ->
    super
      url: '/auth/loading/twitter'
      width: 700
      height: 700,
      response

  App.Models.TwitterProv = TwitterProv
  return App.Models.TwitterProv
