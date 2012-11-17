define [
  "jquery"
  "backbone"
  "app/models/user"
  "app/collections/users"
  "app/models/current_user"
  "app/views/users/show"
  "app/views/users/edit"
  "app/views/users/followingers"
  "app/views/users/find_people"
], ($, Backbone, User, Users, current_user, UserShowView, UserEditView, FollowingersView, FindPeopleView) ->

  class UsersRouter extends Backbone.Router
    initialize: (options) ->
      if options?
        if options.model?
          @model = new User options.model
        if options.collection?
          @collection = new Users options.collection

    routes:
      ":username"             : "show"
      "settings/info"         : "edit"
      ":username/followers"   : "followers"
      ":username/following"   : "following"
      "users/recommended"     : "recommended"
      "users/friends"         : "friends"
      "users/search?q=:query" : "search"

    show: ->
      @view = new UserShowView
        el: $("#header_card.r_user")
        model: @model

    edit: ->
      @view = new UserEditView
        el: $(".container")
        model: @model

    followers: -> @followingers true
    following: -> @followingers false

    followingers: (followers) ->
      @view = new FollowingersView
        followers: followers
        model: @model
        collection: @collection

      $("#yield").html @view.render().el

    recommended: ->
      @collection = Users::recommended()
      @find_people "recommended"

    friends: ->
      @collection = current_user.expats
      @find_people "friends"

    search: (query) ->
      @collection = Users::search query
      @find_people "search"

    find_people: (section) ->
      @collection.fetch()

      @view = new FindPeopleView
        section: section
        collection: @collection

      $("#yield").html @view.render().el
      @view.after_insert()
