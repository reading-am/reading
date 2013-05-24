define [
  "backbone"
  "app/init"
  "app/collections/posts"
], (Backbone, App) ->

  class User extends Backbone.Model
    type: "User"

    initialize: ->
      @has_many "Posts"
      @has_many "Following", "Users"
      @has_many "Followers", "Users"
      @has_many "Expats", "Users"

    signed_in: ->
      return Boolean @get "id"

    access: (perm) ->
      if !perm
        @get("access")
      else
        @get("access") && @get("access").indexOf(perm) isnt -1


  App.Models.User = User
  return User
