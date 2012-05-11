class ø.Models.User extends ø.Backbone.Model
  type: "User"

  initialize: ->
    @has_many "Posts"

class ø.Collections.Users extends ø.Backbone.Collection
  type: "Users"
  model: ø.Models.User
