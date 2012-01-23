class Authorization
  constructor: (@uid, @permissions) ->

  can: (perm) ->
    perm in @permissions

  save: (params) ->
    data =
      authorization: # the id is passed in the url
        permissions: "[\"#{@permissions.join('","')}\"]"
    $.ajax
      url: "/authorizations/#{@provider}/#{@uid}/update.json"
      type: 'POST'
      data: data
      success: (data, textStatus, jqXHR) =>
        params.success() if params.success?
      error: (jqXHR, textStatus, errorThrown) =>
        params.error() if params.error?


Authorization::factory = (params) ->
  type = params.provider[0].toUpperCase() + params.provider[1..-1].toLowerCase() + 'Auth'
  new window[type](params.uid, params.permissions)

class TwitterAuth extends Authorization
  provider: "twitter"
  constructor: (@permissions, @uid) ->
    @permissions ?= TwitterAuth::default_perms
  login: (params={}) ->
    # if permissions have been submitted,
    # check to see if there are new ones
    # and add them. There is no subtracting
    # permissions. That happens on the Provider side
    if params.permissions
      perms = @permissions.concat(params.permissions).unique()
      changed = perms.length > @permissions.length
    else
      perms = @permsissions
      changed = false

    success = params.success ? ->
    error = params.error ? ->

    TwitterProv::login (response) =>
      # the user cancelled the request
      # or there was an error
      unless response.authResponse
        error response
      else
        # another user has the account
        if response.status is "AuthTaken" or @uid is "new" and response.status is "AuthPreexisting"
          error response
        # the user isn't logged into the right
        # account on the provider's site
        else if @uid and @uid is not "new" and response.authResponse.uid != @uid
          error {status: 'AuthWrong'}
        # new account
        else if !@uid
          @uid = response.authResponse.uid
          @permissions = perms
          success response
        # existing account successfully authed
        else
          # if nothing has changed, go ahead
          # and execute the callback
          unless changed
            success response
          else
            # perms have change. Save them and
            # execute the callback
            @permissions = perms
            success response
            # right now to auth is saved in the omniauth
            # callback else we'd need to save it here
            # @save
              # success: ->
                # success response
              # error: ->
                # error "AuthSaveFail"
    , perms

  ask_permission: (perm, success, error) ->
    # already has access
    if @can(perm)
      success()
    else
      TwitterProv::ask_permission =>
        if response.authResponse
          @permissions.push perm
          @save
            success: success
            error: error
        else
          error()

TwitterAuth::default_perms = ["read","write"]

class FacebookAuth extends Authorization
  provider: "facebook"
  ask_permission: (perm, success, error) ->
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
              error()
          ), {scope: perm}
        else
          # the user is logged into the wrong FB account
          failure()


window.Authorization = Authorization
window.TwitterAuth = TwitterAuth
window.FacebookAuth = FacebookAuth
