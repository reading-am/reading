define [
  "app/init"
  "models/authorization"
  "models/kippt_prov"
], (App, Authorization, KipptProv) ->

  class KipptAuth extends Authorization
    provider: "kippt"
    _login: KipptProv::login
    places: (params) ->
      # transform the return val
      if params.success?
        success = params.success
        params.success = (places) ->
          success ({text:place.attributes.table.title, value:place.attributes.table.id} for place in places)

      super params

  App.Models.KipptAuth = KipptAuth
  return KipptAuth
