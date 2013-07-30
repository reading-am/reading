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

    json: ->
      json = super()
      json.avatar = if is_retina then json.avatar_medium else json.avatar_thumb
      json
