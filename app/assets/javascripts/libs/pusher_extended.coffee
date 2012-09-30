define [
  "libs/pusher"
  "app/constants"
], (Pusher, Constants) ->

  Pusher.log = (message) ->
    if Constants.env is "development" and window.console and window.console.log
      window.console.log(message)

  return new Pusher Constants.config.pusher.key
