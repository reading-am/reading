define [
  "underscore"
  "jquery"
  "backbone"
  "app/collections/posts"
  "app/views/posts/posts_grouped_by_page/view"
], (_, $, Backbone, Posts, PostsGroupedByPageView) ->

  class PostsRouter extends Backbone.Router
    initialize: (options) ->
      @collection = options.collection

    routes: {}
