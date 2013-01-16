define [
  "jquery"
  "app/views/posts/post"
  "handlebars"
  "app/views/users/user"
  "text!app/templates/posts/subpost.hbs"
  "text!posts/subpost.css"
], ($, PostView, Handlebars, UserView, template, css) ->
  $("<style>").html(css).appendTo("head")

  class SubPostView extends PostView
    template: Handlebars.compile template

    tagName: "div"
    className: "r_post r_subpost"

    initialize: (options) ->
      @user_view = new UserView model: @model.get("user"), tagName: "div", size: "small"
      super()

    render: =>
      @set_yn()

      @$el.append(@template())
      @$(".body").prepend(@user_view.render().el)

      return this
