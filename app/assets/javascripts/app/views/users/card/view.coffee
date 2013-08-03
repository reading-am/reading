define [
  "underscore"
  "app/models/user_with_current"
  "app/views/users/user/view"
  "text!app/views/users/card/template.mustache"
  "text!app/views/users/card/styles.css"
], (_, User, UserView, template, styles) ->

  class UserCardView extends UserView
    @assets
      template: template
      styles: styles

    initialize: (options) ->
      super options

      @rss_path = options.rss_path
      @populate_follow_state()

    populate_follow_state: ->
      if User::current.signed_in() and @model.id isnt User::current.id
        User::current.following.params.user_ids = [@model.id]
        User::current.following.fetch success: (following) =>
          @model.set is_following: !!following.length
        
    json: ->
      has_avatar = @model.id isnt User::current.id or @model.avatar.indexOf("/default/") is -1
      _.extend super(),
        signed_in:          !!User::current.id
        is_current_user:    @model.id is User::current.id
        avatar_link_url:    if has_avatar then @model.get("avatar") else "/settings/info"
        avatar_link_target: if has_avatar then "_blank" else false
        has_link:           !!@model.get "link"
        has_location:       !!@model.get "location"
        rss_path:           @rss_path
