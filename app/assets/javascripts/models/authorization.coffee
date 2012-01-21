class Authorization
  constructor: (@provider, @uid, @permissions) ->

Authorization::factory = (params) ->
  type = params.provider[0].toUpperCase() + params.provider[1..-1].toLowerCase() + 'Auth'
  new window[type](params.provider, params.uid, params.permissions)

class TwitterAuth extends Authorization

class FacebookAuth extends Authorization
  add_permission: (perm, success, failure) ->
    return success() if @authorizations.facebook.permissions[perm]
    FB.login ((response) ->
      if response.authResponse
        success()
      else
        failure()
    ), {scope: perm}


window.Authorization = Authorization
window.TwitterAuth = TwitterAuth
window.FacebookAuth = FacebookAuth
