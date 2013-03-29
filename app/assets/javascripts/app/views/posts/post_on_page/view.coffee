define [
  "underscore"
  "jquery"
  "app/views/posts/post/view"
  "mustache"
  "app/constants"
  "app/views/users/user/view"
  "text!app/views/posts/post_on_page/template.mustache"
  "text!app/views/posts/post/styles.css"
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
      json = @model.toJSON()
      json.domain = Constants.domain
      json.yep = true if @model.get("yn") is true
      json.nope = true if @model.get("yn") is false

      @$el.html(@template(json))
          .find(".r_post_bg").prepend(@user_view.render().el)

      return this
