define [
  "app/init"
  "models/provider"
], (App, Provider) ->

  class ReadabilityProv extends Provider

  ReadabilityProv::login = (response, perms) ->
    super
      url: '/auth/loading/readability'
      width: 600
      height: 450,
      response

  App.Models.ReadabilityProv = ReadabilityProv
  return ReadabilityProv
