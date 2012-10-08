define [
  "jquery"
  "backbone"
  "handlebars"
  "app/collections/users"
  "app/collections/posts"
  "app/collections/comments"
  "app/views/users/users"
  "app/views/posts/posts"
  "app/views/comments/comments"
  "text!app/templates/admin/dashboard.hbs"
  "text!admin/dashboard.css"
], ($, Backbone, Handlebars, Users, Posts, Comments, UsersView, PostsView, CommentsView, template, css) ->

  $("<style>").html(css).appendTo("head")

  class DashboardView extends Backbone.View
    template: Handlebars.compile template

    initialize: ->
      @users_view = new UsersView
        collection: new Users
      @users_view.collection.monitor().fetch()

      @posts_view = new PostsView
        collection: new Posts
      @posts_view.collection.monitor().fetch()

      @comments_view = new CommentsView
        collection: new Comments
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
