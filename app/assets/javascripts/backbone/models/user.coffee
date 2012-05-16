define [
  "backbone"
  "app"
  "app/collections/posts"
], (Backbone, App) ->

  class App.Models.User extends Backbone.Model
    type: "User"

    initialize: ->
      @has_many "Posts"
      @has_many "Following", "Users"
      @has_many "Followers", "Users"
