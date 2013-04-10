define [
  "jquery"
  "backbone"
  "app/views/pages/pages/view"
], ($, Backbone, PagesView) ->

  class PostsRouter extends Backbone.Router
    initialize: (options) ->
      @collection = options.collection

    routes:
      "(everybody)" : "index"

    index: ->
      @pages_view = new PagesView
        collection: @collection

      $("#yield").html @pages_view.render().el
