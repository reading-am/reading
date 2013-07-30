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

      User::current.following.params.user_ids = [@model.id]
      User::current.following.fetch success: (following) =>
        @model.set is_following: !_.isEmpty(following)

    json: ->
      _.extend super(),
        signed_in:          !!User::current.id
        is_current_user:    @model.id == User::current.id
        avatar_link_url:    @model.avatar
        avatar_link_target: false
        has_link:           !!@model.get "link"
        has_location:       !!@model.get "location"
