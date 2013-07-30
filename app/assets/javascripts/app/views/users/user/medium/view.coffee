define [
  "app/views/users/user/view"
  "text!app/views/users/user/medium/template.mustache"
  "text!app/views/users/user/medium/styles.css"
], (UserView, template, styles) ->

  is_retina = window.devicePixelRatio > 1

  class UserMediumView extends UserView
    @assets
      styles: styles
      template: template

    events:
      "click .r_follow_button .btn" : "toggle_follow"

    toggle_follow: (e) ->
      $tar = @$(e.target)
      $tar.toggleClass "btn-success"
      $tar.text if $tar.is ".btn-success" then "Follow" else "Unfollow"

    json: ->
      json = super()
      json.avatar = if is_retina then json.avatar_medium else json.avatar_thumb
      json
