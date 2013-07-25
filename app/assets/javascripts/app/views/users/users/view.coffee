define [
  "underscore"
  "app/models/user_with_current"
  "app/views/base/collection"
  "app/views/users/user/view"
  "text!app/views/users/user/template.mustache"
], (_, User, CollectionView, UserView, template) ->

  class UsersView extends CollectionView
    @assets
      template: template
    modelView: UserView

    initialize: (options) ->
      @collection.on "sync", @sync, this
      @collection.on "reset", @populate_follow_state, this

      @size = options.size ? "small"
      super options

    sync: ->
      if current = @collection.get User::current
        current.set is_current_user: true

    populate_follow_state: ->
      users = @collection
      User::current.following.params.user_ids = users.pluck "id"
      User::current.following.fetch success: (following) ->
        following.each (user) -> users.get(user).set is_following: true
