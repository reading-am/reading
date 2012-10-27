define [
  "libs/pusher"
  "app/constants"
], (Pusher, Constants) ->

  Pusher.channel_auth_endpoint = "//#{Constants.domain}/pusher/auth"
  # Add the user's token if it's on the page, otherwise the endpoint defaults to current_user
  Pusher.channel_auth_endpoint += "?token=#{reading.token}" if reading?.token?

  # Override the Pusher XHR so we can force cookies to be sent with the auth request
  Pusher.XHR = ->
  Pusher.XHR.prototype = if window.XMLHttpRequest? then new window.XMLHttpRequest() else new ActiveXObject("Microsoft.XMLHTTP")
  Pusher.XHR.prototype.withCredentials = true

  unless Constants.env is "production"

    Pusher.log = (message) ->
      if window.console and window.console.log
        window.console.log(message)

    window.WEB_SOCKET_DEBUG = true # Flash fallback debug flag

    if Constants.env is "development"
      Pusher.host    = "localhost"
      Pusher.ws_port = 8080

  # duplicated from bookmarklet/real_loader
  # This is a hack to prevent consumption of connections on the main site
  # which doesn't currently use any realtime functionality
  on_reading = window.location.host.indexOf(Constants.domain) is 0 or
               window.location.host.indexOf("staging.#{Constants.domain}") is 0 or
               window.location.host.indexOf("0.0.0.0") is 0

  do_connect = !on_reading or (on_reading and window.location.pathname is "/admin/dashboard")

  return new Pusher Constants.config.pusher.key if do_connect
