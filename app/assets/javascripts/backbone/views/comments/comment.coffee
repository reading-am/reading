ø.Views.Comments ||= {}

class ø.Views.Comments.CommentView extends ø.Backbone.View
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
    return false

  new_window: (e) ->
    window.open e.currentTarget.href
    false

  destroy: ->
    if confirm "Are you sure you want to delete this comment?"
      @model.destroy()

    return false

  render: =>
    json = @model.toJSON()
    json.is_owner = @model.get("user").get("id") == ø.Models.Post::current.get("user").get("id")
    ø.$(@el).html(@template(json))
    @$("time").humaneDates()
    child_view = new ø.Views.Users.UserView
      model: @model.get('user')
      el:   @$(".r_user")
    child_view.render()
    return this
