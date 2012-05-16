define [
  "jquery"
  "underscore"
  "backbone"
  "handlebars"
  "app/models/post"
  "app/views/users/user"
  "plugins/humane"
], ($, _, Backbone, Handlebars, Post, UserView) ->

  class CommentView extends Backbone.View
    template: Handlebars.compile "
      <div class=\"r_comment_header\">
        <div class=\"r_user\"></div>
        <time datetime=\"{{updated_at}}\"></time>
        <div class=\"r_comment_actions\">
          {{! <a href=\"#\" class=\"r_reply\">reply</a> }}
          {{#if is_owner}}
            <a href=\"#\" class=\"r_destroy\">delete</a>
          {{/if}}
        </div>
      </div>
      <div class=\"r_comment_body\">
        {{format_comment body}}
      </div>
    "

    tagName: "li"
    className: "r_comment"

    events:
      "click .r_reply" : "reply"
      "click .r_destroy" : "destroy"
      "click a.r_url:not(.r_mention)": "new_window"

    initialize: ->
      @model.bind "change", @render, this
      @model.bind "destroy", @remove, this

    reply: ->
      alert "reply will go here"
      false

    new_window: (e) ->
      window.open e.currentTarget.href
      false

    destroy: ->
      if confirm "Are you sure you want to delete this comment?"
        @model.destroy()

      false

    render: =>
      json = @model.toJSON()
      json.is_owner = @model.get("user").get("id") == Post::current.get("user").get("id")
      $(@el).html(@template(json))

      @$("time").humaneDates()

      child_view = new UserView
        model: @model.get('user')
        el:   @$(".r_user")
      child_view.render()

      return this
