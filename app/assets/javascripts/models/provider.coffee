class Provider
  accounts: ->
    attr for own attr, value of this

# from: http://stackoverflow.com/questions/4358135/how-to-make-omniauth-work-with-a-popup-window
Provider::login = (url, width, height) ->
    screenX = window.screenX ? window.screenLeft
    screenY = window.screenY ? window.screenTop
    outerWidth = window.outerWidth ? document.body.clientWidth
    outerHeight = window.outerHeight ? (document.body.clientHeight - 22)
    left = parseInt(screenX + ((outerWidth - width) / 2), 10)
    top = parseInt(screenY + ((outerHeight - height) / 2.5), 10)
    popup = window.open url, "Login", "width=#{width},height=#{height},left=#{left},top=#{top}"
    popup.focus() if window.focus
    false

class TwitterProv extends Provider

TwitterProv::login = ->
    super '/auth/twitter', 700, 700

class FacebookProv extends Provider

FacebookProv::login = ->
    super '/auth/facebook', 981, 600

window.Provider = Provider
window.TwitterProv = TwitterProv
window.FacebookProv = FacebookProv
