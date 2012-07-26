define [
  "app"
  "models/authorization"
  "models/tssignals_prov"
], (App, Authorization, TssignalsProv) ->

  class TssignalsAuth extends Authorization
    provider: "tssignals"
    _login: TssignalsProv::login
    places: (params) ->
      # transform the return val
      if params.success?
        success = params.success
        params.success = (places) ->
          success ({text:place.name, value:place.id} for place in places)

      super params

  App.Models.TssignalsAuth = TssignalsAuth
  return TssignalsAuth
