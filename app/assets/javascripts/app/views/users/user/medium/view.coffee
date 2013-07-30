define [
  "app/models/user_with_current"
  "app/models/relationship"
  "app/views/users/user/view"
  "text!app/views/users/user/medium/template.mustache"
  "text!app/views/users/user/medium/styles.css"
], (User, Relationship, UserView, template, styles) ->

  is_retina = window.devicePixelRatio > 1

  class UserMediumView extends UserView
    @assets
      styles: styles
      template: template

    events:
      "click .r_follow_button .btn" : "toggle_follow"

    toggle_follow: (e) ->
      $tar = @$(e.target)
      rel  = new Relationship subject: @model, enactor: User::current

      if @model.get "is_following"
        rel.isNew = -> false
        rel.destroy()
        @model.set is_following: false
      else
        rel.save()
        @model.set is_following: true

    json: ->
      json = super()
      json.avatar = if is_retina then json.avatar_medium else json.avatar_thumb
      json
