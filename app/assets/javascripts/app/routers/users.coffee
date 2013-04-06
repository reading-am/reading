define [
  "jquery"
  "backbone"
  "app/models/user"
  "app/collections/users"
  "app/collections/pages"
  "app/views/users/show/view"
  "app/views/users/subnav/view"
  "app/views/pages/pages/view"
  "app/views/pages/pages_with_input/view"
  "app/views/users/edit/view"
  "app/views/users/followingers/view"
  "app/views/users/find_people/view"
], ($, Backbone, User, Users, Pages, UserShowView, UserSubnavView, PagesView, PagesWithInputView, UserEditView, FollowingersView, FindPeopleView) ->

  class UsersRouter extends Backbone.Router
    initialize: (options) ->
      if options?
        if options.model?
          @model = new User options.model
        if options.collection?
          switch options.collection[0].type
            when "User"
              @collection = new Users options.collection
            when "Post"
              @collection = new Pages
              for val in options.collection
                @collection.add val.get("page")
                @collection.get(val.get("page").id).posts.add val

    routes:
      ":username(/list)(/page/:page)" : "show"
      "settings/info"         : "edit"
      ":username/followers"   : "followers"
      ":username/following"   : "following"
      "users/recommended"     : "recommended"
      "users/friends"         : "friends"
      "users/search"          : "search"

    show: (username) ->
      @user_show_view = new UserShowView
        el: $("#header_card.r_user")
        model: @model

      @user_subnav_view = new UserSubnavView
        el: $("#subnav")

      if username is User::current.get("username")
        @pages_view = new PagesWithInputView
          collection: @collection
      else
        @pages_view = new PagesView
          collection: @collection

        $("#subnav").after @pages_view.render().el

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
      @collection = User::current.expats
      @find_people "friends"

    search: ->
      @collection = Users::search @query_params().q
      @find_people "search"

    find_people: (section) ->
      @collection.fetch()

      @view = new FindPeopleView
        section: section
        collection: @collection

      $("#yield").html @view.render().el
      @view.after_insert()
