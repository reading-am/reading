define [
  "jquery"
  "backbone"
  "app/constants"
  "app/collections/users"
  "app/collections/posts"
  "app/collections/comments"
  "app/views/users/users/view"
  "app/views/posts/posts/view"
  "app/views/comments/comments/view"
  "text!app/views/admin/dashboard/template.mustache"
  "text!app/views/admin/dashboard/styles.css"
], ($, Backbone, Constants, Users, Posts, Comments, UsersView, PostsView, CommentsView, template, styles) ->

  class DashboardView extends Backbone.View
    @assets
      styles: styles
      template: template

    initialize: ->
      users = new Users
      users.comparator = (user) -> -user.get("id")
      @users_view = new UsersView collection: users
      @users_view.collection.monitor().fetch()

      posts = new Posts
      posts.comparator = (post) -> -post.get("id")
      @posts_view = new PostsView collection: posts
      @posts_view.collection.monitor().fetch()

      comments = new Comments
      @comments_view = new CommentsView collection: comments
      @comments_view.collection.monitor().fetch()

    render: ->
      @$el.html(@template())

      @$("#users").append(@users_view.render().el)
      @$("#posts").append(@posts_view.render().el)
      @$("#comments").append(@comments_view.render().el)

      # Fill in the counts
      @$(".count").each (i, el) ->
        type = $(el).parents(".module").attr("id")
        $.ajax("/api/v#{Constants.api_version}/#{type}/count").done (msg) ->
          $(el).html msg["total_#{type}"]

      return this
