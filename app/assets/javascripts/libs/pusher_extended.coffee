define [
  "libs/pusher"
  "app/constants"
], (Pusher, Constants) ->

  Pusher.channel_auth_endpoint = "//#{Constants.domain}/pusher/auth"
  # Add the user's token if it's on the page, otherwise the endpoint defaults to current_user
  Pusher.channel_auth_endpoint += "?token=#{reading.token}" if reading?.token?

  # Override the Pusher XHR so we can force cookies to be sent with the auth request
  Pusher.XHR = ->
    xhr = if window.XMLHttpRequest? then new window.XMLHttpRequest() else new ActiveXObject("Microsoft.XMLHTTP")
    xhr.withCredentials = true
    return xhr

  unless Constants.env is "staging"
    Pusher.host    = Constants.config.pusher.host
    Pusher.ws_port = 8080

  unless Constants.env is "production"
    Pusher.log = (message) ->
      if window.console and window.console.log
        window.console.log(message)

    window.WEB_SOCKET_DEBUG = true # Flash fallback debug flag

  return new Pusher Constants.config.pusher.key
