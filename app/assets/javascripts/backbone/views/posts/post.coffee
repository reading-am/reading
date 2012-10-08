define [
  "jquery"
  "backbone"
  "handlebars"
  "app/views/users/user"
  "app/views/pages/page"
  "text!posts/post.css"
], ($, Backbone, Handlebars, UserView, PageView, css) ->
  $("<style>").html(css).appendTo("head")

  class PostView extends Backbone.View
    tagName: "li"
    className: "r_post"

    initialize: (options) ->
      @model.on "change", @render, this
      @model.on "remove", @remove, this

      @user_view = new UserView model: @model.get("user"), size: "small"
      @page_view = new PageView model: @model.get("page")

    set_yn: =>
      # reset for re-renders on update
      @$el.removeClass("r_yep r_nope")

      if @model.get("yn") is true
        @$el.addClass("r_yep")
      else if @model.get("yn") is false
        @$el.addClass("r_nope")

    render: =>
      @set_yn()

      @$el.append(@user_view.render().el)
      @$el.append(@page_view.render().el)

      return this
