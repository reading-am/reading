define [
  "jquery"
  "backbone"
  "app/views/pages/pages/view"
  "app/views/posts/posts_grouped_by_page/view"
], ($, Backbone, PagesView, PostsGroupedByPageView) ->

  class SearchRouter extends Backbone.Router
    initialize: (options) ->
      @collection = options.collection

    routes:
      "search" : "index"

    index: ->
      if @collection.type is 'Pages'
        @pages_view = new PagesView
          collection: @collection
      else
        @pages_view = new PostsGroupedByPageView
          collection: @collection

      $("#yield").html @pages_view.render().el
