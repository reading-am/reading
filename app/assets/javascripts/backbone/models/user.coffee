class ø.Models.User extends ø.Backbone.Model
  type: "User"

  initialize: ->
    @has_many "Posts"
    @has_many "Following", "Users"

class ø.Collections.Users extends ø.Backbone.Collection
  type: "Users"
  model: ø.Models.User
