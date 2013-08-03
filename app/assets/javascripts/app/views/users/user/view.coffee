define [
  "app/models/user_with_current"
  "app/models/relationship"
  "app/views/base/model"
  "app/constants"
  "app/views/users/overlay/view"
  "text!app/views/users/user/styles.css"
], (User, Relationship, ModelView, Constants, UserOverlayView, styles) ->

  class UserView extends ModelView
    @assets
      styles: styles

    events:
      "click .event_show"   : "show"
      "click .event_follow" : "follow"

    show: ->
      if window.location.host.indexOf(Constants.domain) isnt 0
        overlay = new UserOverlayView model: @model
        overlay.render()
        false

    follow: (e) ->
      if !User::current.signed_in()
        window.location = "/sign_in"
        return false

      $tar = @$(e.target)
      rel  = new Relationship subject: @model, enactor: User::current

      if @model.get "is_following"
        rel.isNew = -> false
        rel.destroy()
        @model.set
          is_following: false
          followers_count: @model.get("followers_count") - 1
      else
        rel.save()
        @model.set
          is_following: true
          followers_count: @model.get("followers_count") + 1

      false
