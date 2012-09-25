define [
  "jquery"
  "backbone"
  "app/views/users/user"
  "text!bookmarklet/post.css"
], ($, Backbone, UserView, css) ->
  $("<style>").html(css).appendTo("head")

  class PostView extends Backbone.View
    tagName: "li"
    className: "r_post"

    render: =>
      if @model.get("yn") is true
        @$el.addClass("r_yep")
      else if @model.get("yn") is false
        @$el.addClass("r_nope")

      @user_view = new UserView model: @model.get("user"), size: "small"
      @$el.html(@user_view.render().el)

      return this
