define [
  "jquery"
  "underscore"
  "backbone"
  "app/init"
  "app/models/user"
], ($, _, Backbone, App, User) ->

  # TODO - this uses its own save and sync methods
  # it'd be better if it used the Backbone methods

  class Authorization extends Backbone.Model
    type: "Authorization"
    default_perms: ["read","write"]

    initialize: (options) ->
      @uid = options.uid
      @info = options.info
      @name = @uid

      @permissions = options.permissions || []
      # make sure you grab certain default permissions on a new authorization
      @permissions = _.uniq(@permissions.concat(@default_perms)) if !@uid or @uid is "new"

      if @info?
        if @info.username?
          @name = @info.username
        else if @info.name?
          @name = @info.name

    can: (perm) ->
      @uid and @uid != "new" and @permissions and perm in @permissions

    sync_to_current_session: (success, error) ->
      $.ajax # hit the omniauth endpointk
        url: "/users/auth/#{@provider}/callback"
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
        @initialize uid: response.auth.uid, permissions: response.auth.permissions, info: response.auth.info
        User::current.get("authorizations")[@provider].set(@uid, this)

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
