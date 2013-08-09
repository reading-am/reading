define [
  "underscore"
  "app/models/user_with_current"
  "app/views/base/collection/view"
  "app/views/users/user/small/view"
  "text!app/views/users/users/small/template.mustache"
], (_, User, CollectionView, UserSmallView, template) ->

  class UsersView extends CollectionView
    @assets
      template: template

    modelView: UserSmallView

    initialize: (options) ->
      super options
      @collection.on "sync", (col, resp)  => @populate_follow_state _.pluck(resp.users, "id")
      @collection.on "reset", (col, opt)  => @populate_follow_state col.pluck("id")

    populate_follow_state: (ids) ->
      # if there are users in the collection and,
      # if there's only one user, it's not the current user
      if User::current.signed_in() && @collection.length && !(@collection.length is 1 and @collection.first.id is User::current.id)
        users = @collection
        User::current.following.params =
          limit: ids.length
          user_ids: ids
        User::current.following.fetch success: (following) ->
          following.each (user) -> users.get(user).set is_following: true

      if current = @collection.get User::current
        current.set is_current_user: true
