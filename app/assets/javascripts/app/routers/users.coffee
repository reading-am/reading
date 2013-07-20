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
  "app/views/posts/medium_selector/view"
  "app/views/components/loading_collection/view"
  "app/views/pages/pages/view"
  "app/views/pages/pages_with_input/view"
  "app/views/posts/posts_grouped_by_page/view"
  "app/views/users/edit/view"
  "app/views/users/followingers/view"
  "app/views/users/find_people/view"
  "extend/jquery/waypoints"
], (_, $, Backbone, User, Users, Posts, UserShowView, UserSubnavView, SettingsSubnavView, MediumSelectorView,
LoadingCollectionView, PagesView, PagesWithInputView, PostsGroupedByPageView, UserEditView, FollowingersView, FindPeopleView) ->

  class UsersRouter extends Backbone.Router

    routes:
      "settings/info"         : "edit"
      "settings/extras"       : "extras"
      "users/recommended"     : "recommended"
      "users/friends"         : "friends"
      "users/search"          : "search"
      ":username/followers"   : "followers"
      ":username/following"   : "following"
      "(:username)(/:type)(/:medium)" : "show"

    show: (username, type, medium) ->
      if username is "everybody"
        username = null
      if type isnt "list" and type isnt "posts"
        medium = type
        type = "posts"
      if !medium
        medium = "all"

      @collection ?= new Posts

      if !@setup
        @setup = true
        if @model
          if type is "list"
            @model.following.has_many "Posts"
            @model.following.posts.reset @collection.models
            @collection = @model.following.posts
          else
            @model.posts.reset @collection.models
            @collection = @model.posts

      @collection.medium = medium
      @collection.monitor()

      @loading_view ?= new LoadingCollectionView
        el: @$yield.find(".r_loading")

      @medium_selector_view ?= new MediumSelectorView
        el: $("#medium_selector")
        start_val: medium
        on_change: (medium) =>
          @navigate "#{
            if username then username else ""
          }#{
            if type is "list" then "/#{type}" else ""
          }#{
            if medium isnt "all" then "/#{medium}" else ""
          }", trigger: true

      if username
        @user_show_view ?= new UserShowView
          el: $("#header_card.r_user")
          model: @model

        @user_subnav_view ?= new UserSubnavView
          el: $("#subnav")

      if username is User::current.get("username")
        @pages_view ?= new PagesWithInputView
          collection: @collection
      else
        @pages_view ?= new PostsGroupedByPageView
          collection: @collection

      after_render = =>
        @loading_view.$el.hide()
        @pages_view.$el.waypoint "destroy" # reset any existing waypoint
        @pages_view.$(".r_pages").css opacity: 1

        if @collection.length >= @collection.params.limit
          @pages_view.$el.waypoint (direction) =>
            if direction is "down"
              @loading_view.$el.show()
              @pages_view.$el.waypoint "disable"
              @collection.fetchNextPage success: (collection, data) =>
                more = data?[collection.type.toLowerCase()]?.length >= collection.params.limit
                @loading_view.$el.hide()
                # This is on a delay because the waypoints plugin will miscalculate
                # the offset if rendering the new DOM elements hasn't finished
                setTimeout =>
                  @pages_view.$el.waypoint(if more then "enable" else "destroy")
                , 2000
          , {offset: "bottom-in-view"}

      if $.contains @$yield[0], @pages_view.el
        # Render with new data from API
        @pages_view.$(".r_pages").css opacity: 0.2
        @collection.fetch
          reset: true
          success: after_render
      else
        # Initial render with bootstrapped data
        @$yield.prepend @pages_view.render().el
        after_render()

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

      @$yield.html @view.render().el

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

      @$yield.html @view.render().el
      @view.after_insert()
