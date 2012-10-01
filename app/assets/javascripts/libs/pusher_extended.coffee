define [
  "libs/pusher"
  "app/constants"
], (Pusher, Constants) ->

  Pusher.channel_auth_endpoint = "//#{Constants.domain}/pusher/auth"
  # Add the user's token if it's on the page, otherwise the endpoint defaults to current_user
  Pusher.channel_auth_endpoint += "?token=#{reading.token}" if reading?.token?

  if Constants.env is "development"

    Pusher.log = (message) ->
      if window.console and window.console.log
        window.console.log(message)

    window.WEB_SOCKET_DEBUG = true # Flash fallback debug flag

    Pusher.host    = "localhost"
    Pusher.ws_port = 8080

  return new Pusher Constants.config.pusher.key
