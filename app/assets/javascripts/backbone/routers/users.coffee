reading.define [
  "jquery"
  "backbone"
  "app/models/user"
  "app/collections/users"
  "app/views/users/followingers"
  "app/views/users/find_people"
], ($, Backbone, User, Users, FollowingersView, FindPeopleView) ->

  class UsersRouter extends Backbone.Router
    initialize: (options) ->
      if options.model?
        @model = new User options.model
      if options.collection?
        @collection = new Users options.collection

    routes:
      ":username/followers" : "followers"
      ":username/following" : "following"
      "users/recommended" : "recommended"

    followers: -> @followingers true
    following: -> @followingers false

    followingers: (followers) ->
      @view = new FollowingersView
        followers: followers
        model: @model
        collection: @collection
      $("#yield").html @view.render().el

    recommended: ->
      @view = new FindPeopleView collection: @collection
      $("#yield").html @view.render().el
