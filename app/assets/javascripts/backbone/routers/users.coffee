reading.define [
  "jquery"
  "backbone"
  "app/models/user"
  "app/collections/users"
  "app/views/users/followingers"
], ($, Backbone, User, Users, FollowingersView) ->

  class UsersRouter extends Backbone.Router
    initialize: (options) ->
      if options.model?
        @model = new User options.model
      if options.collection?
        @collection = new Users options.collection

    routes:
      ":username/followers" : "followers"
      ":username/following" : "following"

    followers: -> @followingers true
    following: -> @followingers false

    followingers: (followers) ->
      @view = new FollowingersView
        followers: followers
        model: @model
        collection: @collection
      $("#yield").html @view.render().el
