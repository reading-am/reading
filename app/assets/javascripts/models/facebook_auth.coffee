define [
  "underscore"
  "app"
  "models/authorization"
], (_, App, Authorization) ->

  class FacebookAuth extends Authorization
    provider: "facebook"

    set_default_perms: (@permissions) ->
      @permissions = _.uniq(@permissions.concat(["email"])) if !@uid or @uid is "new"

    login: (params={}) ->
      success = params.success ? ->
      error   = params.error ? ->
      perms   = params.permissions ? []

      FB.getLoginStatus (response) =>
        if response.status is "connected" and @uid
          if @uid is "new" and current_user.get("authorizations")[@provider][response.authResponse.userID]
            error_status = "AuthPreexisting"
          else if @uid isnt "new" and String(response.authResponse.userID) isnt @uid
            error_status = "AuthWrongAccount"

        if error_status?
          response.status = error_status
          error response
        else
          # facebook will choke if you request the permission "installed"
          # even though it's passed back in their permissions array
          perms = _.uniq(@permissions.concat(perms))
          if installed = perms.indexOf "installed" > -1
            perms = perms.splice installed, 1
          FB.login (response) =>
            if response.authResponse
              @sync_to_current_session success, error
            else # the user denied authorization!
              response.status = "AuthFailure"
              error response
          , {scope: perms.join ','}
  
  App.Models.FacebookAuth = FacebookAuth
  return FacebookAuth
