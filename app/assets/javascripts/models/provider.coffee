class Provider
  accounts: ->
    attr for own attr, value of this

  login: (width, height) ->
    screenX = window.screenX ? window.screenLeft
    screenY = window.screenY ? window.screenTop
    outerWidth = window.outerWidth ? document.body.clientWidth
    outerHeight = window.outerHeight ? (document.body.clientHeight - 22)
    left = parseInt(screenX + ((outerWidth - width) / 2), 10)
    top = parseInt(screenY + ((outerHeight - height) / 2.5), 10)
    newwindow = window.open auth_url, "Login", "width=#{width},height=#{height},left=#{left},top=#{top}"
    newwindow.focus() if window.focus
    false

class TwitterProv extends Provider
  auth_url: '/auth/twitter'

class FacebookProv extends Provider
  auth_url: '/auth/facebook'

window.Provider = Provider
window.TwitterProv = TwitterProv
window.FacebookProv = FacebookProv
