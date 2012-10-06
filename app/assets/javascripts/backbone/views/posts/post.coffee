define [
  "jquery"
  "backbone"
  "handlebars"
  "app/constants"
  "app/views/users/user"
  "text!app/templates/posts/post.hbs"
  "text!posts/post.css"
], ($, Backbone, Handlebars, Constants, UserView, template, css) ->
  $("<style>").html(css).appendTo("head")

  class PostView extends Backbone.View
    template: Handlebars.compile template

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
      @$el.html(@template(json))
          .find(".r_post_bg").prepend(@user_view.render().el)

      return this
