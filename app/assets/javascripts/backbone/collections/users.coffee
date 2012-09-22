define [
  "backbone"
  "app/init"
  "app/models/user"
], (Backbone, App, User) ->

  class Users extends Backbone.Collection
    type: "Users"
    model: User

  Users::recommended = ->
    collection = new this.constructor

    collection._url = collection.url
    collection.url = -> "#{@_url()}/recommended"

    return collection


  App.Collections.Users = Users
  return Users
