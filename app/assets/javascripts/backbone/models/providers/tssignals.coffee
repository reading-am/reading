define [
  "app/init"
  "app/models/providers/provider"
], (App, Provider) ->

  class TssignalsProv extends Provider
    type: "TssignalsProv"

  TssignalsProv::login = (response, perms) ->
    super
      url: '/auth/loading/37signals'
      width: 700
      height: 430,
      response

  App.Models.TssignalsProv = TssignalsProv
  return App.Models.TssignalsProv
