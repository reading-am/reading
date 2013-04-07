define [
  "jquery"
  "backbone"
  "app/views/hooks/index/view"
  "app/views/users/settings_subnav/view"
], ($, Backbone, HooksIndexView, SettingsSubnavView) ->

  class HooksRouter extends Backbone.Router

    routes:
      "settings/hooks" : "index"

    index: ->
      @settings_subnav_view = new SettingsSubnavView
        el: $("#subnav")

      # TODO - this should instantiate a HooksIndexView
      # but for the moment that code hasn't been ported
      # to Backbone so it inits when require()'d
