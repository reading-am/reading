define [
  "jquery"
  "backbone"
  "handlebars"
  "app/views/users/user"
  "text!app/templates/posts/post.hbs"
  "text!posts/post.css"
], ($, Backbone, Handlebars, UserView, template, css) ->
  $("<style>").html(css).appendTo("head")

  class PostView extends Backbone.View
    template: Handlebars.compile template

    tagName: "li"
    className: "r_post"

    render: =>
      json = @model.toJSON()

      if json.posts?
        json.post_before = json.posts[0] if json.posts[0]? and json.posts[0].id > -1
        json.post_after = json.posts[1] if json.posts[1]? and json.posts[1].id > -1

      if @model.get("yn") is true
        @$el.addClass("r_yep")
      else if @model.get("yn") is false
        @$el.addClass("r_nope")

      @user_view = new UserView model: @model.get("user"), size: "small"
      @$el.html(@template(json))
          .find(".r_yep_nope").after(@user_view.render().el)

      return this
