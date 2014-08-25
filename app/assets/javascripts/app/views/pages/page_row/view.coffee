define [
  "underscore"
  "jquery"
  "app/models/user"
  "app/views/base/model"
  "app/views/pages/page/view"
  "app/views/posts/post_actions/view"
  "app/views/posts/subposts/view"
  "app/collections/posts"
  "app/views/comments/comments_with_input/view"
  "text!app/views/pages/page_row/template.mustache"
  "text!app/views/pages/page_row/styles.css"
  "app/models/page" # this needs preloading
], (_, $, User, ModelView, PageView, PostActionsView, SubPostsView, Posts, CommentsWithInputView, template, styles) ->

  class PageRowView extends ModelView
    @assets
      template: template
      styles: styles

    events:
      "click .posts_icon": "show_posts"
      "click .comments_icon": "show_comments"

    initialize: ->
      super
      @model.posts.on "remove", => @remove() if @model.posts.length is 0

      @page_view = new PageView model: @model
      @post_actions = new PostActionsView
        collection: @model.posts
        user: User::current
        page: @model
      @posts_view = new SubPostsView collection: @model.posts
      @comments_view = new CommentsWithInputView
        collection: @model.comments
        user: User::current
        page: @model

    show_posts: ->
      @show_many "posts"

    show_comments: ->
      @show_many "comments"

    show_many: (type, callback) ->
      other = if type is "posts" then "comments" else "posts"
      type_view = @["#{type}_view"]
      other_view = @["#{other}_view"]

      @["#{type}_icon"].hide()
      @["#{other}_icon"].show()

      other_view.$el.slideUp()

      if type_view.collection.length < @model.get("#{type}_count")
        type_view.collection.fetch success: =>
          type_view.$el.slideDown()
      else
        type_view.status_view?.sync() or
        type_view.subview.status_view.sync()
        
        type_view.$el.slideDown()

      false

    remove: ->
      @$el.slideUp => @$el.remove()

    render: =>
      json =
        posts_count: @model.get("posts_count")
        has_comments: !!@model.get("comments_count")
        comments_count: @model.get("comments_count")

      yn_avg = @model.posts.yn_average()
      if yn_avg > 0
        json.yn_class = "yep"
        json.yep = true
      else if yn_avg < 0
        json.yn_class = "nope"
        json.nope = true

      @$el.html(@template(json))

      @posts_icon = @$(".posts_icon")
      @comments_icon = @$(".comments_icon")

      @body = @$(".posts_group_wrapper")
      @body
        .append(@page_view.render().el)
        .append(@post_actions.render().el)
        .append(@posts_view.render().el)
        .append(@comments_view.render().$el.hide())

      @comments_view.attach_autocomplete()

      return this
