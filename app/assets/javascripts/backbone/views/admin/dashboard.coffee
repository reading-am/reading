define [
  "underscore"
  "jquery"
  "backbone"
  "mustache"
  "app/collections/users"
  "app/collections/posts"
  "app/collections/comments"
  "app/views/users/users"
  "app/views/posts/posts"
  "app/views/comments/comments"
  "text!app/templates/admin/dashboard.hbs"
  "text!admin/dashboard.css"
], (_, $, Backbone, Handlebars, Users, Posts, Comments, UsersView, PostsView, CommentsView, template, css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class DashboardView extends Backbone.View
    template: Handlebars.compile template

    initialize: ->
      load_css()

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
        $.ajax("/api/#{type}/count").done (msg) ->
          $(el).html msg["total_#{type}"]

      return this
