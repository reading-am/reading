define [
  "libs/pusher"
  "app/constants"
], (Pusher, Constants) ->

  if Constants.env is "development"

    Pusher.log = (message) ->
      if window.console and window.console.log
        window.console.log(message)

    Pusher.host    = "localhost"
    Pusher.ws_port = 8080

  return new Pusher Constants.config.pusher.key
