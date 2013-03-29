define [
  "app/views/base/model"
  "mustache"
  "app/constants"
  "app/views/users/popover"
  "text!app/templates/users/user.mustache"
], (ModelView, Mustache, Constants, UserPopoverView, template) ->

  is_retina = window.devicePixelRatio > 1

  class UserView extends ModelView
    template: Mustache.compile template

    tagName: "div"
    className: "r_user"

    events:
      "click a:not(.r_tagalong)" : "show"

    initialize: (options) ->
      @size = options.size ? "medium"
      super()

    show: ->
      if window.location.host.indexOf(Constants.domain) isnt 0
        popover = new UserPopoverView model: @model
        popover.render()
        false

    render: =>
      json = @model.toJSON()

      switch @size
        when "small"
          json.avatar = if is_retina then json.avatar_thumb else json.avatar_mini
          delete json.bio
          delete json.username
        when "medium"
          json.avatar = if is_retina then json.avatar_medium else json.avatar_thumb

      @$el
        .addClass("r_size_#{@size}")
        .html(@template(json))

      return this
