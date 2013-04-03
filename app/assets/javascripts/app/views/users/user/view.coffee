define [
  "underscore"
  "jquery"
  "app/views/base/model"
  "mustache"
  "app/constants"
  "app/views/users/popover/view"
  "text!app/views/users/user/template.mustache"
  "text!app/views/users/user/styles.css"
], (_, $, ModelView, Mustache, Constants, UserPopoverView, template, css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  is_retina = window.devicePixelRatio > 1

  class UserView extends ModelView
    @parse_template template

    events:
      "click a:not(.r_tagalong)" : "show"

    initialize: (options) ->
      @size = options.size ? "medium"
      load_css()
      super()

    show: ->
      if window.location.host.indexOf(Constants.domain) isnt 0
        popover = new UserPopoverView model: @model
        popover.render()
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

