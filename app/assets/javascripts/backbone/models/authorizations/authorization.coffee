define [
  "require"
  "jquery"
  "underscore"
  "backbone"
  "app/init"
], (require, $, _, Backbone, App) ->

  class Authorization extends Backbone.Model
    type: "Authorization"

    initialize: (options) ->
      @uid = options.uid
      @permissions = options.permissions || []
      @info = options.info

      @name = @uid

      if @info?
        if @info.username?
          @name = @info.username
        else if @info.name?
          @name = @info.name

      @set_default_perms @permissions

    # make sure you grab certain default permissions on a new authorization
    set_default_perms: (@permissions) ->
      @permissions = _.uniq(@permissions.concat(["read","write"])) if !@uid or @uid is "new"

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
        # rerun the constructor
        @constructor response.auth.uid, response.auth.permissions, response.auth.info
        require("app/models/current_user").get("authorizations")[@provider][@uid] = this

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
    new App.Models[type]
      uid: params.uid
      permissions: params.permissions
      info: params.info

  App.Models.Authorization = Authorization
  return Authorization
