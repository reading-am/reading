reading.define [
  "app"
  "models/provider"
], (App, Provider) ->

  class TssignalsProv extends Provider

  TssignalsProv::login = (response, perms) ->
    super
      url: '/auth/loading/37signals'
      width: 700
      height: 700,
      response

  App.Models.TssignalsProv = TssignalsProv
  return App.Models.TssignalsProv
