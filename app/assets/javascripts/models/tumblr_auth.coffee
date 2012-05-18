define [
  "app"
  "models/authorization"
], (App, Authorization) ->

  class App.Models.TumblrAuth extends Authorization
    provider: "tumblr"
    _login: App.Models.TumblrProv::login
    places: (params) ->
      # transform the return val
      if params.success?
        success = params.success
        params.success = (places) ->
          success ({text:place.title, value:place.name} for place in places)

      super params
