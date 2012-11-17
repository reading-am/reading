define [
  "app/init"
  "app/models/providers/provider"
], (App, Provider) ->

  class ReadabilityProv extends Provider
    type: "ReadabilityProv"

  ReadabilityProv::login = (response, perms) ->
    super
      url: '/auth/loading/readability'
      width: 600
      height: 450,
      response

  App.Models.ReadabilityProv = ReadabilityProv
  return ReadabilityProv
