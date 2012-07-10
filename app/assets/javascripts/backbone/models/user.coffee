reading.define [
  "backbone"
  "app"
  "app/collections/posts"
], (Backbone, App) ->

  class User extends Backbone.Model
    type: "User"

    initialize: ->
      @has_many "Posts"
      @has_many "Following", "Users"
      @has_many "Followers", "Users"
      @has_many "Expats", "Users"

    logged_in: ->
      return Boolean @get "id"

    can: (perm, provider, uid) ->
      uid = String uid
      i = 0
      while i < @get("authorizations")[provider].length
        return true if @get("authorizations")[provider][i].uid is uid and perm in @get("authorizations")
        i++
      false

  App.Models.User = User
  return User
