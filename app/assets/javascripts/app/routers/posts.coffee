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

    routes:
      "(everybody)(/posts)(/page/:page)" : "index"

    index: (page) ->
      @collection = new Posts if _.isEmpty @collection

      page ||= @query_params().page
      @collection.monitor()

      @pages_view = new PostsGroupedByPageView
        collection: @collection

      $("#yield").html @pages_view.render().el
