define [
  "jquery"
  "app/views/base/model"
  "mustache"
  "app/views/pages/page"
  "app/views/posts/subposts"
  "app/collections/posts"
  "app/models/current_user"
  "app/views/comments/comments_with_input"
  "text!app/templates/pages/page_row.mustache"
  "app/models/page" # this needs preloading
], ($, ModelView, Mustache, PageView, SubPostsView, Posts, current_user, CommentsWithInputView, template) ->

  class PageRowView extends ModelView
    template: Mustache.compile template

    tagName: "div"
    className: "row w_rule"

    events:
      "click .has_posts": "show_posts"
      "click .has_comments": "show_comments"

    initialize: ->
      @page_view = new PageView model: @model, tagName: "div"
      @posts_view = new SubPostsView collection: @model.posts
      @comments_view = new CommentsWithInputView
        collection: @model.comments
        user: current_user
        page: @model

    show_posts: ->
      @show_many "posts"

    show_comments: ->
      @show_many "comments"

    show_many: (type) ->
      other = if type is "posts" then "comments" else "posts"
      type_view = @["#{type}_view"]
      other_view = @["#{other}_view"]

      @["#{type}_button"].hide()
      @["#{other}_button"].show()

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

      @$el.append(@template(json))

      @posts_button = @$(".has_posts")
      @comments_button = @$(".has_comments")

      @body = @$(".posts_group")
      @body
        .append(@page_view.render().el)
        .append(@posts_view.render().el)
        .append(@comments_view.render().$el.hide())

      @comments_view.attach_autocomplete()

      return this
