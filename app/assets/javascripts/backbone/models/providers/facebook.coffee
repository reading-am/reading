define [
  "app/init"
  "app/models/providers/provider"
], (App, Provider) ->

  class FacebookProv extends Provider
    type: "FacebookProv"

  FacebookProv::login = (response, perms) ->
    super
      url: '/users/auth/loading/facebook'
      width: 981
      height: 600,
      response

  App.Models.FacebookProv = FacebookProv
  return FacebookProv
