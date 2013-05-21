define [
  "app/views/base/model"
  "app/constants"
  "app/views/users/overlay/view"
  "text!app/views/users/user/template.mustache"
  "text!app/views/users/user/styles.css"
], (ModelView, Constants, UserOverlayView, template, styles) ->

  is_retina = window.devicePixelRatio > 1

  class UserView extends ModelView
    @assets
      styles: styles
      template: template

    events:
      "click a:not(.r_tagalong)" : "show"

    initialize: (options) ->
      @size = options.size ? "medium"
      super options

    show: ->
      if window.location.host.indexOf(Constants.domain) isnt 0
        overlay = new UserOverlayView model: @model
        overlay.render()
        false

    render: =>
      json = @model.toJSON()
      json.size = @size

      switch @size
        when "small"
          json.avatar = if is_retina then json.avatar_thumb else json.avatar_mini
          delete json.bio
          delete json.username
        when "medium"
          json.avatar = if is_retina then json.avatar_medium else json.avatar_thumb

      @$el.html(@template(json))

      return this

