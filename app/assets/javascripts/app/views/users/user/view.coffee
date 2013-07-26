define [
  "app/views/base/model"
  "app/constants"
  "app/views/users/overlay/view"
  "text!app/views/users/user/styles.css"
], (ModelView, Constants, UserOverlayView, styles) ->

  class UserView extends ModelView
    @assets
      styles: styles

    events:
      "click a:not(.r_tagalong)" : "show"

    show: ->
      if window.location.host.indexOf(Constants.domain) isnt 0
        overlay = new UserOverlayView model: @model
        overlay.render()
        false
