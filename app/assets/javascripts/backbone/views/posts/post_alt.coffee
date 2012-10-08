define [
  "jquery"
  "backbone"
  "handlebars"
  "app/constants"
  "app/views/users/user"
  "app/views/pages/page"
  "text!posts/post.css"
], ($, Backbone, Handlebars, Constants, UserView, PageView, css) ->
  $("<style>").html(css).appendTo("head")

  class PostView extends Backbone.View
    tagName: "li"
    className: "r_post"

    initialize: (options) ->
      @model.bind "change", @render, this
      @model.bind "remove", @remove

    remove: =>
      @$el.slideUp => @$el.remove()

    render: =>
      json = @model.toJSON()
      json.domain = Constants.domain

      # reset for re-renders on update
      @$el.removeClass("r_yep r_nope")

      if @model.get("yn") is true
        @$el.addClass("r_yep")
      else if @model.get("yn") is false
        @$el.addClass("r_nope")

      @user_view = new UserView model: @model.get("user"), size: "small"
      @page_view = new PageView model: @model.get("page")

      @$el.append(@user_view.render().el)
      @$el.append(@page_view.render().el)

      return this
