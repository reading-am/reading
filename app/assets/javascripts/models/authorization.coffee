#################
# Authorization #
#################
class Authorization
  constructor: (@uid, @permissions = [], @info) ->
    # make sure you grab certain default permissions on a new authorization
    @permissions = @permissions.concat(["read","write"]).unique() if !@uid or @uid is "new"

  can: (perm) ->
    @uid and @uid != "new" and @permissions and perm in @permissions

  sync_to_current_session: (success, error) ->
    $.ajax # hit the omniauth endpointk
      url: "/auth/#{@provider}/callback"
      dataType: "json"
      data:
        return_type: "json",
      success: (response) =>
        if response.status is "AuthTaken"
          error response
        else
          @assign_params_from_auth_response response
          success response
      error: ->
        error {status: "AuthSaveFail"}

  assign_params_from_auth_response: (response) ->
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

  places: (params) ->
    $.ajax
      url: "/authorizations/#{@provider}/#{@uid}/places.json"
      success: (data, textStatus, jqXHR) =>
        params.success(data.response.places) if params.success?
      error: (jqXHR, textStatus, errorThrown) =>
        params.error() if params.error?


  ask: (perm, success, error) ->
    # already has access
    if @can(perm)
      success()
    else
      perms = @permissions.slice 0 # copy the array
      perms.push perm
      @login
        permissions: perms,
        success: (response) =>
          if @can perm then success response else error response
        error: error

  login: (params={}) ->
    success = params.success ? ->
    error = params.error ? ->

    @_login (response) =>
      if (!response.authResponse) or (response.status is "AuthTaken") or (@uid is "new" and response.status is "AuthPreexisting")
        error response
      else if @uid and @uid isnt "new" and response.authResponse.uid isnt @uid
        # the user isn't logged into the right account on the provider's site
        response.status = "AuthWrongAccount"
        error response
      else
        @assign_params_from_auth_response response
        success response

Authorization::factory = (params) ->
  type = params.provider[0].toUpperCase() + params.provider[1..-1].toLowerCase() + 'Auth'
  new window[type](params.uid, params.permissions, params.info)


###############
# TwitterAuth #
###############
class TwitterAuth extends Authorization
  provider: "twitter"
  _login: TwitterProv::login


###############
# TumblrAuth #
###############
class TumblrAuth extends Authorization
  provider: "tumblr"
  _login: TumblrProv::login


##################
# InstapaperAuth #
##################
class InstapaperAuth extends Authorization
  provider: "instapaper"
  _login: InstapaperProv::login


################
# FacebookAuth #
################
class FacebookAuth extends Authorization
  provider: "facebook"

  constructor: (@uid, @permissions = []) ->
    # make sure you grab certain default permissions on a new authorization
    @permissions = @permissions.concat(["email","offline_access"]).unique() if !@uid or @uid is "new"

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
        # facebook will choke if you request the permission "installed"
        # even though it's passed back in their permissions array
        perms = @permissions.concat(perms).unique()
        if installed = perms.indexOf "installed" > -1
          perms = perms.splice installed, 1
        FB.login (response) =>
          if response.authResponse
            @sync_to_current_session success, error
          else # the user denied authorization!
            response.status = "AuthFailure"
            error response
        , {scope: perms.join ','}


# add to window scope
window.Authorization = Authorization
window.TwitterAuth = TwitterAuth
window.FacebookAuth = FacebookAuth
window.TumblrAuth = TumblrAuth
window.InstapaperAuth = InstapaperAuth
