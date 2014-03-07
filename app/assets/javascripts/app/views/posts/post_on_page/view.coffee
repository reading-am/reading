define [
  "app/views/posts/post/view"
  "app/constants"
  "app/views/users/user/small/view"
  "text!app/views/posts/post_on_page/template.mustache"
  "text!app/views/posts/post/styles.css"
], (PostView, Constants, UserSmallView, template, styles) ->

  class PostOnPageView extends PostView
    @assets
      styles: styles
      template: template

    initialize: (options) ->
      @post = @model.posts.first()
      
      @post.on "change", @render, this
      @post.on "remove", @remove, this

      @user_view = new UserSmallView
        model: @model

    remove: ->
      @$el.slideUp => @$el.remove()

    json: ->
      json = @post.toJSON()
      json.domain = Constants.domain
      json.yep = true if @post.get("yn") is true
      json.nope = true if @post.get("yn") is false
      return json

    render: ->
      @$el.html(@template(@json()))
          .find(".r_post_bg").prepend(@user_view.render().el)

      return this
