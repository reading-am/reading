define [
  "jquery"
  "backbone"
  "app/views/pages/pages/view"
], ($, Backbone, PagesView) ->

  class SearchRouter extends Backbone.Router
    initialize: (options) ->
      @collection = options.collection

    routes:
      "search" : "index"

    index: ->
      @pages_view = new PagesView
        collection: @collection

      $("#yield").html @pages_view.render().el
