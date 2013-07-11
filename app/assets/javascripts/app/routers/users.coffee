define [
  "underscore"
  "jquery"
  "backbone"
  "app/models/user_with_current"
  "app/collections/users"
  "app/collections/posts"
  "app/views/users/show/view"
  "app/views/users/subnav/view"
  "app/views/users/settings_subnav/view"
  "app/views/pages/pages/view"
  "app/views/pages/pages_with_input/view"
  "app/views/posts/posts_grouped_by_page/view"
  "app/views/users/edit/view"
  "app/views/users/followingers/view"
  "app/views/users/find_people/view"
], (_, $, Backbone, User, Users, Posts, UserShowView, UserSubnavView, SettingsSubnavView, PagesView,
PagesWithInputView, PostsGroupedByPageView, UserEditView, FollowingersView, FindPeopleView) ->

  class UsersRouter extends Backbone.Router
    initialize: (options) ->
      if options?.model?
        @model = options.model
      if options?.collection?
        @collection = options.collection

    routes:
      ":username(/list)(/posts)(/page/:page)" : "show"
      "settings/info"         : "edit"
      "settings/extras"       : "extras"
      ":username/followers"   : "followers"
      ":username/following"   : "following"
      "users/recommended"     : "recommended"
      "users/friends"         : "friends"
      "users/search"          : "search"

    show: (username, page) ->
      @collection = new Posts if _.isEmpty @collection

      @user_show_view = new UserShowView
        el: $("#header_card.r_user")
        model: @model

      @user_subnav_view = new UserSubnavView
        el: $("#subnav")

      path = window.location.pathname.split("/")
      is_feed = path[path.length-3] == "list" || ((path[path.length-1] == "list" && username != "list") || path[path.length-2] == "list")
      @collection.endpoint = => "users/#{@model.get("id")}/#{if is_feed then "following/events" else "events"}"
      @collection.limit = 100
      @collection.offset = 200
      @collection.monitor()

      if username is User::current.get("username")
        @pages_view = new PagesWithInputView
          collection: @collection
      else
        @pages_view = new PostsGroupedByPageView
          collection: @collection

      @pages_view.render()
      @collection.fetch reset: true, success: =>
        $("#yield").html @pages_view.el

    edit: ->
      @settings_subnav_view = new SettingsSubnavView
        el: $("#subnav")

      @view = new UserEditView
        el: $(".container")
        model: @model

    settings: ->
      @settings_subnav_view = new SettingsSubnavView
        el: $("#subnav")

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
      @view = new FindPeopleView
        section: section
        collection: @collection

      @view.collection.fetch()

      $("#yield").html @view.render().el
      @view.after_insert()
