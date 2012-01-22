class Authorization
  constructor: (@uid, @permissions) ->

  can: (perm) ->
    perm in @permissions

Authorization::factory = (params) ->
  type = params.provider[0].toUpperCase() + params.provider[1..-1].toLowerCase() + 'Auth'
  new window[type](params.uid, params.permissions)

class TwitterAuth extends Authorization
  ask_permission: (perm, success, failure) ->
    # already has access
    if @can(perm)
      success()
    else
      # do something

class FacebookAuth extends Authorization
  ask_permission: (perm, success, failure) ->
    return alert 'fb add'
    # already has access
    if @can(perm)
      success()
    else
      FB.getLoginStatus (response) ->
        if response.status isnt "connected" or (response.status is "connected" and String(response.authResponse.userID) is @uid)
          # either the user is logged into the right account or
          # they're not connected at all so we can go ahead and
          # log them in with the requested scope
          FB.login ((response) ->
            if response.authResponse
              # authorized and good to go
              success()
            else
              # the user denied authorized!
              failure()
          ), {scope: perm}
        else
          # the user is logged into the wrong FB account
          failure()


window.Authorization = Authorization
window.TwitterAuth = TwitterAuth
window.FacebookAuth = FacebookAuth
