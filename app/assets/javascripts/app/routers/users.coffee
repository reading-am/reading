define [
  "underscore"
  "jquery"
  "backbone"
  "app/models/user_with_current"
  "app/models/domain"
  "app/collections/users"
  "app/collections/posts"
  "app/collections/oauth_apps"
  "app/collections/oauth_access_tokens"
  "app/views/users/card/view"
  "app/views/users/subnav/view"
  "app/views/users/settings_subnav/view"
  "app/views/posts/medium_selector/view"
  "app/views/posts/yn_selector/view"
  "app/views/pages/pages/view"
  "app/views/pages/pages_with_input/view"
  "app/views/posts/posts_grouped_by_page/view"
  "app/views/users/users/view"
  "app/views/users/user/medium/view"
  "app/views/users/edit/view"
  "app/views/oauth_apps/oauth_apps_with_input/view"
  "app/views/oauth_access_tokens/oauth_access_tokens/view"
], (_, $, Backbone, User, Domain, Users, Posts, OauthApps, OauthAccessTokens, UserCardView, UserSubnavView,
SettingsSubnavView, MediumSelectorView, YnSelectorView, PagesView,
PagesWithInputView, PostsGroupedByPageView, UsersView, UserMediumView,
UserEditView, OauthAppsWithInputView, OauthAccessTokensView) ->

  class UsersRouter extends Backbone.Router

    routes:
      "settings/info"         : "edit"
      "settings/apps"         : "apps"
      "settings/apps/dev"     : "dev_apps"
      "settings/extras"       : "settings"
      "users/recommended"     : "recommended"
      "users/friends"         : "friends"
      "users/search"          : "search"
      "domains/(:domain)(/:type)(/:medium)(/:yn)" : "show"
      ":username/follow:suffix" : "followingers"
      "(:username)(/:type)(/:medium)(/:yn)" : "show"

    show: (username, type, medium="all", yn="any") ->
      # Parse params
      if !username
        username = "everybody"
      if type isnt "list" and type isnt "posts"
        yn = medium
        medium = type
        type = "posts"

      # Setup collection
      @collection ?= new Posts
      models = @collection.models

      if @model
        c = if type is "posts" then @model.posts else (@model.following.posts || @model.following.has_many("Posts"))
        @collection = c if @collection isnt c

      @collection.medium = medium
      @collection.params.yn = yn

      @collection.monitor()

      @medium_selector_view ?= new MediumSelectorView
        el: $("#medium_selector")[0]
        start_val: medium
        on_change: (medium) =>
          @navigate construct_url(), trigger: true

      @yn_selector_view ?= new YnSelectorView
        el: $("#yn_selector")[0]
        start_val: yn
        on_change: (yn) =>
          @navigate construct_url(), trigger: true

      construct_url = =>
        medium = @medium_selector_view.value()
        yn = @yn_selector_view.value()
        "#{
          if @model?.type is "Domain" then "domains/" else ""
        }#{
          username
        }#{
          if type is "list" then "/#{type}" else ""
        }#{
          if yn isnt "any" or medium isnt "all" then "/#{medium}" else ""
        }#{
          if yn isnt "any" then "/#{yn}" else ""
        }"

      if username isnt "everybody"
        @user_card_view ?= new UserCardView
          el: $("#header_card.r_user")[0]
          model: @model
          rss_path: "#{username}/#{type}#{
            if medium isnt "all" then "/#{medium}" else ""
          }.rss"

        @user_subnav_view ?= new UserSubnavView
          el: $("#subnav")[0]

      p_props =
        collection: @collection
        subview_el: $(".r_pages")[0]

      if username is User::current.get("username")
        @pages_view ?= new PagesWithInputView p_props
        col_view = @pages_view.subview
      else
        @pages_view ?= new PostsGroupedByPageView p_props
        col_view = @pages_view

      rendered = $.contains @$yield[0], @pages_view.el

      if rendered
        # Render with new data from API
        @pages_view.$(".r_pages").css opacity: 0.2
        @collection.fetch
          reset: true
          success: => @pages_view.$(".r_pages").css opacity: 1
      else
        # Initial render with bootstrapped data
        @$yield.prepend @pages_view.render().el
        col_view.progressive_render()
        @collection.reset models # data renders the subviews

        col_view.infinite_scroll()
        @pages_view.$(".r_pages").css opacity: 1

    edit: ->
      @settings_subnav_view = new SettingsSubnavView
        el: $("#subnav")

      @view = new UserEditView
        el: $(".container")
        model: @model

    settings: ->
      @settings_subnav_view = new SettingsSubnavView
        el: $("#subnav")

    apps: ->
      @collection = new OauthAccessTokens if !@collection.length

      @settings_subnav_view = new SettingsSubnavView
        el: $("#subnav")
      
      @tokens_view = new OauthAccessTokensView
        collection: @collection

      @$yield.html @tokens_view.render().el

    dev_apps: ->
      @collection = new OauthApps if !@collection.length

      @settings_subnav_view = new SettingsSubnavView
        el: $("#subnav")
      
      @apps_view = new OauthAppsWithInputView
        collection: @collection
        owner: User::current

      @apps_view.collection.trigger "reset" # updates the status
      @$yield.html @apps_view.render().el

    followingers: (username, suffix) ->
      @user_card_view ?= new UserCardView
        el: $("#header_card.r_user")
        model: @model

      @users_view ?= new UsersView
        collection: @model["follow#{suffix}"]
        modelView: UserMediumView
      # This populates the follow state and must happen
      # after the collection has been added to the view
      @users_view.collection.reset @collection.models

      @$yield.prepend @users_view.render().el

    recommended: ->
      @find_people Users::recommended(), "recommended"

    friends: ->
      @find_people User::current.expats, "expats"

    search: ->
      @find_people Users::search @query_params().q, "search"

    find_people: (collection, section) ->
      models = @collection.models
      @collection = collection

      @users_view ?= new UsersView
        el: @$yield.find(".r_users")[0]
        collection: @collection
        modelView: UserMediumView

      @collection.reset models
      @$yield.prepend @users_view.el

      @users_view.infinite_scroll()
