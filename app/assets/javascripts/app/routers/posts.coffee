define [
  "jquery"
  "backbone"
  "app/views/posts/posts_grouped_by_page/view"
], ($, Backbone, PostsGroupedByPageView) ->

  class PostsRouter extends Backbone.Router
    initialize: (options) ->
      @collection = options.collection

    routes:
      "(everybody)(/posts)(/page/:page)" : "index"

    index: (page) ->
      page ||= @query_params().page
      @collection.monitor() unless page > 1

      @pages_view = new PostsGroupedByPageView
        collection: @collection

      $("#yield").html @pages_view.render().el
