define [
  "jquery"
  "backbone"
  "app/views/admin/dashboard"
], ($, Backbone, DashboardView) ->

  class AdminRouter extends Backbone.Router

    routes:
      "admin/dashboard" : "dashboard"

    dashboard: (id) ->
      @view = new DashboardView
      $("#yield").html @view.render().el
