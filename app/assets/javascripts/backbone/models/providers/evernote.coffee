define [
  "app/init"
  "app/models/providers/provider"
], (App, Provider) ->

  class EvernoteProv extends Provider
    type: "EvernoteProv"

  EvernoteProv::login = (response, perms) ->
    super
      url: '/auth/loading/evernote'
      width: 600
      height: 450,
      response

  App.Models.EvernoteProv = EvernoteProv
  return EvernoteProv
