define [
  "underscore"
  "jquery"
  "backbone"
  "app/models/user_with_current"
  "app/collections/users"
  "app/collections/posts"
  "app/views/users/card/view"
  "app/views/users/subnav/view"
  "app/views/users/settings_subnav/view"
  "app/views/posts/medium_selector/view"
  "app/views/components/loading_collection/view"
  "app/views/pages/pages/view"
  "app/views/pages/pages_with_input/view"
  "app/views/posts/posts_grouped_by_page/view"
  "app/views/users/users/view"
  "app/views/users/user/medium/view"
  "app/views/users/edit/view"
  "app/views/users/find_people/view"
], (_, $, Backbone, User, Users, Posts, UserCardView, UserSubnavView,
SettingsSubnavView, MediumSelectorView, LoadingCollectionView, PagesView,
PagesWithInputView, PostsGroupedByPageView, UsersView, UserMediumView,
UserEditView, FindPeopleView) ->

  class UsersRouter extends Backbone.Router

    routes:
      "settings/info"         : "edit"
      "settings/extras"       : "extras"
      "users/recommended"     : "recommended"
      "users/friends"         : "friends"
      "users/search"          : "search"
      ":username/follow:suffix" : "followingers"
      "(:username)(/:type)(/:medium)" : "show"

    show: (username, type, medium) ->
      # Parse params
      if !username
        username = "everybody"
      if type isnt "list" and type isnt "posts"
        medium = type
        type = "posts"
      if !medium
        medium = "all"

      # Setup collection
      @collection ?= new Posts

      if @model
        c = if type is "posts" then @model.posts else (@model.following.posts || @model.following.has_many("Posts"))
        if @collection isnt c
          c.reset @collection.models
          @collection = c

      @collection.medium = medium
      @collection.monitor()

      # Setup views
      @loading_view ?= new LoadingCollectionView
        el: @$yield.find(".r_loading")

      @medium_selector_view ?= new MediumSelectorView
        el: $("#medium_selector")
        start_val: medium
        on_change: (medium) =>
          @navigate "#{
            username
          }#{
            if type is "list" then "/#{type}" else ""
          }#{
            if medium isnt "all" then "/#{medium}" else ""
          }", trigger: true

      if username isnt "everybody"
        @user_card_view ?= new UserCardView
          el: $("#header_card.r_user")
          model: @model
          rss_path: "#{username}/#{type}#{
            if medium isnt "all" then "/#{medium}" else ""
          }.rss"

        @user_subnav_view ?= new UserSubnavView
          el: $("#subnav")

      if username is User::current.get("username")
        @pages_view ?= new PagesWithInputView
          collection: @collection
      else
        @pages_view ?= new PostsGroupedByPageView
          collection: @collection

      # Render
      after_render = =>
        @loading_view.$el.hide()
        @pages_view.$(".r_pages").css opacity: 1
        @pages_view.subview.infinite_scroll
          loading_start:  => @loading_view.$el.show()
          loading_finish: => @loading_view.$el.hide()

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

    followingers: (username, suffix) ->
      c = @model["follow#{suffix}"]
      c.reset @collection.models
      @collection = c

      window.c = @collection
      @user_card_view ?= new UserCardView
        el: $("#header_card.r_user")
        model: @model

      @loading_view ?= new LoadingCollectionView
        el: $(".r_loading")

      @users_view ?= new UsersView
        collection: @collection
        modelView: UserMediumView

      @$yield.prepend @users_view.render().el

      @loading_view.$el.hide()
      @users_view.infinite_scroll
        loading_start:  => @loading_view.$el.show()
        loading_finish: => @loading_view.$el.hide()

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

      @view.collection.fetch reset: true

      @$yield.html @view.render().el
      @view.after_insert()
