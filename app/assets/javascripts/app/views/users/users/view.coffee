define [
  "underscore"
  "app/models/user_with_current"
  "app/views/base/collection"
  "app/views/users/user/small/view"
  "text!app/views/users/users/template.mustache"
], (_, User, CollectionView, UserSmallView, template) ->

  class UsersView extends CollectionView
    @assets
      template: template
    
    modelView: UserSmallView

    initialize: (options) ->
      @collection.on "sync", @sync, this
      @collection.on "reset", @populate_follow_state, this

      # If the collection has been bootstrapped, get follow state
      @populate_follow_state() if @collection.length

      super options

    sync: ->
      if current = @collection.get User::current
        current.set is_current_user: true

    populate_follow_state: ->
      users = @collection
      User::current.following.params.user_ids = users.pluck "id"
      User::current.following.fetch success: (following) ->
        following.each (user) -> users.get(user).set is_following: true
