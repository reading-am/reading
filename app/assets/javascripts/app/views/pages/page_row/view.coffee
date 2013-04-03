define [
  "jquery"
  "app/models/user"
  "app/views/base/model"
  "mustache"
  "app/views/pages/page/view"
  "app/views/posts/subposts/view"
  "app/collections/posts"
  "app/views/comments/comments_with_input/view"
  "text!app/views/pages/page_row/template.mustache"
  "app/models/page" # this needs preloading
], ($, User, ModelView, Mustache, PageView, SubPostsView, Posts, CommentsWithInputView, template) ->

  class PageRowView extends ModelView
    @parse_template template
      
    events:
      "click .posts_icon": "show_posts"
      "click .comments_icon": "show_comments"

    initialize: ->
      @page_view = new PageView model: @model, tagName: "div"
      @posts_view = new SubPostsView collection: @model.posts
      @comments_view = new CommentsWithInputView
        collection: @model.comments
        user: User::current
        page: @model

    show_posts: ->
      @show_many "posts"

    show_comments: ->
      @show_many "comments"

    show_many: (type) ->
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
        type_view.$el.slideDown()

      false

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

      @$el.append(@template(json))

      @posts_icon = @$(".posts_icon")
      @comments_icon = @$(".comments_icon")

      @body = @$(".posts_group")
      @body
        .append(@page_view.render().el)
        .append(@posts_view.render().el)
        .append(@comments_view.render().$el.hide())

      @comments_view.attach_autocomplete()

      return this
