class Provider
  accounts: ->
    attr for own attr, value of this

  login: (url, width, height) ->
    screenX = window.screenX ? window.screenLeft
    screenY = window.screenY ? window.screenTop
    outerWidth = window.outerWidth ? document.body.clientWidth
    outerHeight = window.outerHeight ? (document.body.clientHeight - 22)
    left = parseInt(screenX + ((outerWidth - width) / 2), 10)
    top = parseInt(screenY + ((outerHeight - height) / 2.5), 10)
    newwindow = window.open url, "Login", "width=#{width},height=#{height},left=#{left},top=#{top}"
    newwindow.focus() if window.focus
    false

class TwitterProv extends Provider
  login: ->
    super '/auth/twitter', 400, 400

class FacebookProv extends Provider
  login: ->
    super '/auth/facebook', 400, 400

window.Provider = Provider
window.TwitterProv = TwitterProv
window.FacebookProv = FacebookProv
