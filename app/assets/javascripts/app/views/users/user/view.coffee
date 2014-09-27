define [
  "app/models/user_with_current"
  "app/models/relationship"
  "app/models/blockage"
  "app/views/base/model"
  "app/constants"
  "app/views/users/overlay/view"
  "text!app/views/users/user/styles.css"
], (User, Relationship, Blockage, ModelView, Constants, UserOverlayView, styles) ->

  class UserView extends ModelView
    @assets
      styles: styles

    events:
      "click .event_show"   : "show"
      "click .event_follow" : "follow"
      "click .r_block" : "block"

    show: ->
      if window.location.host.indexOf(Constants.domain) isnt 0
        overlay = new UserOverlayView model: @model
        overlay.render()
        false

    follow: ->
      if !User::current.signed_in()
        window.location = "/sign_in"
        return false

      rel = new Relationship follower: User::current, followed: @model

      if @model.get "is_following"
        rel.isNew = -> false # needed to make destroy work
        rel.destroy()
        @model.set
          is_following: false
          followers_count: @model.get("followers_count") - 1
      else
        if !@model.get("is_blocking") or confirm "Following this user will unblock them. Are you sure you want to continue?"
          rel.save()
          @model.set
            is_following: true
            is_blocking: false
            followers_count: @model.get("followers_count") + 1

      false

    block: ->
      if !User::current.signed_in()
        window.location = "/sign_in"
        return false

      blk = new Blockage blocker: User::current, blocked: @model

      if @model.get "is_blocking"
        if confirm "Are you sure you'd like to unblock this user? Once you do, you'll both be able to see each other's posts and comments."
          blk.isNew = -> false # needed to make destroy work
          blk.destroy()
          @model.set is_blocking: false
      else
        if confirm "Would you like to block this user? Blocking a user will hide your posts and comments from their view and vice versa. It's here to help protect our community members but is in no way a perfect solution. If you continue to have trouble, please don't hesitate to contact us so we can nip it in the bud."
          blk.save()
          @model.set
            is_blocking: true
            is_following: false

      false
