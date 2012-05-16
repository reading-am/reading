define ["backbone","app/models/user"], (Backbone, User) ->

  class Users extends Backbone.Collection
    type: "Users"
    model: User
