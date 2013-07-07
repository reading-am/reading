define [
  "libs/pusher"
  "app/constants"
], (Pusher, Constants) ->

  # Override the Pusher XHR so we can force cookies to be sent with the auth request
  Pusher.XHR = ->
    xhr = if window.XMLHttpRequest? then new window.XMLHttpRequest() else new ActiveXObject("Microsoft.XMLHTTP")
    xhr.withCredentials = true
    return xhr

  config = disableStats: true

  config.authEndpoint = "//#{Constants.domain}/pusher/auth"
  # Add the user's token if it's on the page, otherwise the endpoint defaults to current_user
  config.authEndpoint += "?token=#{reading.token}" if reading?.token?

  #unless Constants.env is "staging"
  if Constants.env is "development"
    config.wsHost   = Constants.config.pusher.host
    config.httpHost = Constants.config.pusher.host
    config.wsPort   = 8080

  if Constants.env is "production"
    config.encrypted = true
  else
    config.encrypted = false
    Pusher.log = (message) ->
      if window.console and window.console.log
        window.console.log(message)

    window.WEB_SOCKET_DEBUG = true # Flash fallback debug flag

  # Stats must be disabled for the 2.0 lib because it tries to call window.Pusher
  return new Pusher Constants.config.pusher.key, config
