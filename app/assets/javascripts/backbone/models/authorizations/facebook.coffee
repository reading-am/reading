define [
  "require"
  "underscore"
  "jquery"
  "app/init"
  "app/models/authorizations/authorization"
], (require, _, $, App, Authorization) ->

  # A NOTE ON THE FACEBOOK JS SDK:
  # The version of this file before this note was added worked well.
  # We checked getLoginStatus and then, in the callback, called login
  # if we needed additional auth. But Safari's popup blocker is
  # aggressive and wouldn't open the login popup from a callback.
  # So now we have to try guessing when the loginStatus should be refeshed

  # if there's been an error with login, start checking login status
  # when the user leaves the window (to switch accounts) and then returns
  check_login_on_focus = false
  $(window).focus ->
    FB.getLoginStatus $.noop, true if check_login_on_focus

  class FacebookAuth extends Authorization
    type: "FacebookAuth"
    provider: "facebook"

    set_default_perms: (@permissions) ->
      @permissions = _.uniq(@permissions.concat(["email"])) if !@uid or @uid is "new"

    login: (params={}) ->
      perms   = params.permissions ? []
      success = (response) ->
        check_login_on_focus = false
        params.success response if params.success?
      error   = (response) ->
        check_login_on_focus = true
        params.error response if params.error?

      authResponse = FB.getAuthResponse()

      error_status = @_check_authResponse authResponse
      if error_status
        error status: error_status, authResponse: authResponse
      else
        # facebook will choke if you request the permission "installed"
        # even though it's passed back in their permissions array
        perms = _.uniq(@permissions.concat(perms))
        if installed = perms.indexOf "installed" > -1
          perms = perms.splice installed, 1

        FB.login (response) =>
          error_status = if response.authResponse \
                         then @_check_authResponse response.authResponse \
                         else "AuthFailure" # the user denied authorization!
          if error_status
            response.status = error_status
            error response
          else
            @sync_to_current_session success, error

        , {scope: perms.join ','}


    _check_authResponse: (authResponse) ->
      if authResponse and @uid
        if @uid is "new" and require("app/models/current_user").get("authorizations")[@provider].get(authResponse.userID)
          error_status = "AuthPreexisting"
        else if @uid isnt "new" and String(authResponse.userID) isnt @uid
          error_status = "AuthWrongAccount"

      return error_status


  App.Models.FacebookAuth = FacebookAuth
  return FacebookAuth
