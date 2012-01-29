class User
  constructor: (params) ->
    @id             = params.id
    @username       = params.username
    @display_name   = params.display_name
    @authorizations = params.authorizations
  logged_in: ->
    return Boolean @id
  can: (perm, provider, uid) ->
    uid = String uid
    i = 0
    while i < @authorizations[provider].length
      return true if @authorizations[provider][i].uid is uid and perm in @authorizations
      i++
    false


window.User = User
