############
# Provider #
############
class Provider
  accounts: ->
    attr for own attr, value of this

# from: http://stackoverflow.com/questions/4358135/how-to-make-omniauth-work-with-a-popup-window
Provider::login = (params, response) ->
  # TODO I don't like that this is scoped to Provider
  # but it works as a shared space for the redirect.html.erb response
  Provider::login.response = response ? ->

  screenX = window.screenX ? window.screenLeft
  screenY = window.screenY ? window.screenTop
  outerWidth = window.outerWidth ? document.body.clientWidth
  outerHeight = window.outerHeight ? (document.body.clientHeight - 22)
  left = parseInt(screenX + ((outerWidth - params.width) / 2), 10)
  top = parseInt(screenY + ((outerHeight - params.height) / 2.5), 10)
  popup = window.open params.url, "Login", "width=#{params.width},height=#{params.height},left=#{left},top=#{top}"
  popup.focus() if window.focus
  false


###############
# TwitterProv #
###############
class TwitterProv extends Provider

TwitterProv::login = (response, perms) ->
  super
    url: '/auth/loading/twitter'
    width: 700
    height: 700,
    response


################
# FacebookProv #
################
class FacebookProv extends Provider

FacebookProv::login = (response, perms) ->
  super
    url: '/auth/loading/facebook'
    width: 981
    height: 600,
    response


# add to window scope
window.Provider = Provider
window.TwitterProv = TwitterProv
window.FacebookProv = FacebookProv
