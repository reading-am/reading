define [
  "backbone"
  "handlebars"
  "models/current_user"
  "app/views/users/user"
  "plugins/humane"
], (Backbone, Handlebars, current_user, UserView) ->

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

    render: =>
      json = @model.toJSON()
      json.is_owner = @model.get("user").get("id") == current_user.get("id")
      @$el.html(@template(json))

      @$("time").humaneDates()

      child_view = new UserView
        model: @model.get('user')
        el:   @$(".r_user")
      child_view.render()

      return this
