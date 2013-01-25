define [
  "underscore"
  "jquery"
  "app/views/posts/post"
  "mustache"
  "app/constants"
  "app/views/users/user"
  "text!app/templates/posts/post_on_page.mustache"
  "text!posts/post.css"
], (_, $, PostView, Mustache, Constants, UserView, template, css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class PostOnPageView extends PostView
    template: Mustache.compile template

    initialize: ->
      # because we don't call super(), this CSS needs to be loaded
      load_css()

      @model.on "change", @render, this
      @model.on "remove", @remove

      @user_view = new UserView model: @model.get("user"), size: "small"

    remove: =>
      @$el.slideUp => @$el.remove()

    render: =>
      @set_yn()

      json = @model.toJSON()
      json.domain = Constants.domain

      @$el.html(@template(json))
          .find(".r_post_bg").prepend(@user_view.render().el)

      return this
