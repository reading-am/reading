define [
  "jquery"
  "backbone"
  "app/views/hooks/index/view"
], ($, Backbone, HooksIndexView) ->

  class HooksRouter extends Backbone.Router

    routes:
      "settings/hooks" : "index"

    index: ->
      # TODO - this should instantiate a HooksIndexView
      # but for the moment that code hasn't been ported
      # to Backbone so it inits when require()'d
