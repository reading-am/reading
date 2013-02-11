define [
  "app/init"
  "app/models/providers/provider"
], (App, Provider) ->

  class FlattrProv extends Provider
    type: "FlattrProv"

  FlattrProv::login = (response, perms) ->
    super
      url: '/users/auth/loading/flattr'
      width: 700
      height: 700,
      response

  App.Models.FlattrProv = FlattrProv
  return FlattrProv
