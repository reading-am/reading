reading.define [
  "backbone"
  "handlebars"
  "app/constants"
  "app/views/users/popover"
], (Backbone, Handlebars, Constants, UserPopoverView) ->

  is_retina = window.devicePixelRatio > 1

  class UserView extends Backbone.View
    template: Handlebars.compile "
      <a href=\"{{url}}\">
        <img src=\"{{avatar}}\"> {{display_name}}
      </a>
      {{#post_before}}<a href=\"{{wrapped_url}}\" class=\"r_tagalong r_before\" title=\"{{title}}\">&laquo;</a>{{/post_before}}{{#post_after}}<a href=\"{{wrapped_url}}\" class=\"r_tagalong r_after\" title=\"{{title}}\">&raquo;</a>{{/post_after}}
    "

    tagName: "li"
    className: "r_user"

    events:
      "click a:not(.r_tagalong)" : "show"

    initialize: (options) ->
      @size = options.size ? "medium"

    show: ->
      if window.location.host.indexOf(Constants.domain) isnt 0
        popover = new UserPopoverView model: @model
        popover.render()
        false

    render: =>
      json = @model.toJSON()

      json.post_before = json.posts[0] if json.posts[0]? and json.posts[0].id > -1
      json.post_after = json.posts[1] if json.posts[1]? and json.posts[1].id > -1

      switch @size
        when "small"
          json.avatar = if is_retina then json.avatar_thumb else json.avatar_mini
        when "medium"
          json.avatar = json.avatar_thumb

      @$el.html(@template(json))
      return this
