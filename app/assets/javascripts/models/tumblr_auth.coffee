define [
  "app/init"
  "models/authorization"
  "models/tumblr_prov"
], (App, Authorization, TumblrProv) ->

  class TumblrAuth extends Authorization
    provider: "tumblr"
    _login: TumblrProv::login
    places: (params) ->
      # transform the return val
      if params.success?
        success = params.success
        params.success = (places) ->
          success ({text:place.title, value:place.name} for place in places)

      super params

  App.Models.TumblrAuth = TumblrAuth
  return TumblrAuth
