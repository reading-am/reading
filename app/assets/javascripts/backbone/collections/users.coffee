define [
  "backbone"
  "app"
  "app/models/user"
], (Backbone, App, User) ->

  class App.Collections.Users extends Backbone.Collection
    type: "Users"
    model: User
