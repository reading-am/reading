define [
  "app/init"
  "app/models/authorizations/authorization"
  "app/models/providers/tumblr"
], (App, Authorization, TumblrProv) ->

  class TumblrAuth extends Authorization
    type: "TumblrAuth"
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
