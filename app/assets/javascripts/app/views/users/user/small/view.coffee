define [
  "app/views/users/user/view"
  "text!app/views/users/user/small/template.mustache"
  "text!app/views/users/user/small/styles.css"
], (UserView, template, styles) ->

  is_retina = window.devicePixelRatio > 1

  class UserSmallView extends UserView
    @assets
      styles: styles
      template: template

    json: ->
      json = super()
      json.avatar_mini = json.avatar_thumb if is_retina
      json
