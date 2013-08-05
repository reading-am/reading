define [
  "underscore"
  "app/models/user_with_current"
  "app/views/base/collection"
  "app/views/users/user/small/view"
  "text!app/views/users/users/small/template.mustache"
], (_, User, CollectionView, UserSmallView, template) ->

  class UsersView extends CollectionView
    @assets
      template: template

    modelView: UserSmallView

    initialize: (options) ->
      @collection.on "sync", @sync, this
      @collection.on "reset", @reset, this

      # If the collection has been bootstrapped, get follow state
      @reset @collection if @collection.length

      super options

    sync: (collection, resp, options) ->
      if current = @collection.get User::current
        current.set is_current_user: true

      if User::current.signed_in()
        @populate_follow_state _.pluck(resp.users, "id")

    reset: (collection) ->
      if User::current.signed_in()
        @populate_follow_state collection.pluck("id")

    populate_follow_state: (ids) ->
      users = @collection
      User::current.following.params =
        limit: ids.length
        user_ids: ids
      User::current.following.fetch success: (following) ->
        following.each (user) -> users.get(user).set is_following: true
