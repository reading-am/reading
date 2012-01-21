class User
  constructor: (params) ->
    @id             = params.id
    @username       = params.username
    @display_name   = params.display_name
    @authorizations = params.authorizations
  logged_in: ->
    return Boolean @id
  accounts: (provider) ->
    auth.uid for auth in @authorizations[provider]
  can: (perm, provider, uid) ->
    i = 0
    while i < @authorizations[provider].length
      return true if @authorizations[provider][i].uid is uid and $.inArray(perm, @authorizations[provider][i].permissions) > -1
      i++
    false


window.User = User
