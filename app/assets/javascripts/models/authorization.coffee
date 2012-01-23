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

  constructor: (@uid, @permissions) ->
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
      if (!response.authResponse) or (response.status is "AuthTaken") or (@uid is "new" and response.status is "AuthPreexisting")
        error response
      else if @uid and @uid isnt "new" and response.authResponse.uid isnt @uid
        # the user isn't logged into the right account on the provider's site
        error {status: 'AuthWrongAccount'}
      else
        if !@uid or @uid is "new"
          # new account
          @uid = response.authResponse.uid
          @permissions = perms
          current_user.authorizations[@provider][@uid] = this
          success response
        else
          # existing account successfully authed
          unless changed
            # if nothing has changed, go ahead and execute the callback
            success response
          else
            # perms have changed so save them and execute the callback
            @permissions = perms
            success response

            # right now to auth is saved in the omniauth callback else we'd need to save it here
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

  constructor: (@uid, @permissions) ->
    @permissions ?= FacebookAuth::default_perms

  can: (perm) ->
    super FacebookAuth::denormalize_perm perm

  login: (params={}) ->
    success = params.success ? ->
    error = params.error ? ->

    FB.getLoginStatus (response) =>
      if response.status is "connected" and @uid
        if @uid is "new" and current_user.authorizations[@provider][response.authResponse.userID]
          error_status = "AuthPreexisting"
        else if String(response.authResponse.userID) isnt @uid
          error_status = "AuthWrongAccount"

      if error_status?
        response.status = error_status
        error response
      else
       if params.permissions
          perms = @permissions.concat(params.permissions).unique()
          changed = perms.length > @permissions.length
        else
          perms = @permsissions
          changed = false

        FB.login (response) =>
          if response.authResponse
            # authorized and good to go
            unless changed
              success response
            else
              @permissions = perms
              @save
                success: ->
                  success response
                error: ->
                  error "AuthSaveFail"
          else
            # the user denied authorization!
            error response
        , {scope: perms.join ','}
  ask_permission: (perm, success, error) ->
    perm = FacebookAuth::denormalize_perm perm
    # already has access
    if @can(perm)
      success()
    else
      perms = @permissions.slice 0 # copy the array
      perms.push perm
      @login
        permissions: perms,
        success: success
        error: error

FacebookAuth::default_perms = ["email","offline_access"]

FacebookAuth::denormalize_perm = (perm) ->
  perm = "offline_access" if perm is "read"
  perm = "publish_stream" if perm is "write"
  perm



window.Authorization = Authorization
window.TwitterAuth = TwitterAuth
window.FacebookAuth = FacebookAuth
