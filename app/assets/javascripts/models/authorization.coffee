class Authorization
  constructor: (@uid, @permissions) ->

  can: (perm) ->
    perm in @permissions

  sync_to_current_session: (success, error) ->
    # hit the omniauth endpoint perm the omniauth-facebook
    # github instructions
    $.ajax
      url: "/auth/#{@provider}/callback"
      dataType: "json"
      data:
        return_type: "json",
      success: (response) =>
        if response.status is "AuthTaken"
          error response
        else
          @sync_params_from_auth_response response
          success response
      error: ->
        error {status: "AuthSaveFail"}
      # need to field AuthTaken error here

  sync_params_from_auth_response: (response) ->
    unless !response.auth
      @uid = response.auth.uid
      @permissions = response.auth.permissions
      current_user.authorizations[@provider][@uid] = this

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

  ask_permission: (perm, success, error) ->
    # already has access
    if @can(perm)
      success()
    else
      perms = @permissions.slice 0 # copy the array
      perms.push perm
      @login
        permissions: perms,
        success: =>
          if @can perm then success() else error()
        error: error

Authorization::factory = (params) ->
  type = params.provider[0].toUpperCase() + params.provider[1..-1].toLowerCase() + 'Auth'
  new window[type](params.uid, params.permissions)

class TwitterAuth extends Authorization
  provider: "twitter"

  constructor: (@uid, @permissions) ->
    @permissions ?= TwitterAuth::default_perms

  login: (params={}) ->
    success = params.success ? ->
    error = params.error ? ->

    TwitterProv::login (response) =>
      if (!response.authResponse) or (response.status is "AuthTaken") or (@uid is "new" and response.status is "AuthPreexisting")
        error response
      else if @uid and @uid isnt "new" and response.authResponse.uid isnt @uid
        # the user isn't logged into the right account on the provider's site
        response.status = "AuthWrongAccount"
        error response
      else
        @sync_params_from_auth_response response
        success response


TwitterAuth::default_perms = ["read","write"]

class FacebookAuth extends Authorization
  provider: "facebook"

  constructor: (@uid, @permissions) ->
    @permissions ?= FacebookAuth::default_perms

  login: (params={}) ->
    success = params.success ? ->
    error   = params.error ? ->
    perms   = params.permissions ? []

    FB.getLoginStatus (response) =>
      if response.status is "connected" and @uid
        if @uid is "new" and current_user.authorizations[@provider][response.authResponse.userID]
          error_status = "AuthPreexisting"
        else if @uid isnt "new" and String(response.authResponse.userID) isnt @uid
          error_status = "AuthWrongAccount"

      if error_status?
        response.status = error_status
        error response
      else
        FB.login (response) =>
          if response.authResponse
            @sync_to_current_session success, error
          else # the user denied authorization!
            response.status = "AuthFailure"
            error response
        , {scope: @permissions.concat(perms).unique().join ','}

FacebookAuth::default_perms = ["email","offline_access"]

# add to window scope
window.Authorization = Authorization
window.TwitterAuth = TwitterAuth
window.FacebookAuth = FacebookAuth
