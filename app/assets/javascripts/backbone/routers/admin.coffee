define [
  "jquery"
  "backbone"
  "app/views/admin/header"
  "app/views/admin/dashboard"
], ($, Backbone, HeaderView, DashboardView) ->

  class AdminRouter extends Backbone.Router

    routes:
      "admin/dashboard" : "dashboard"

    dashboard: (id) ->
      @header = new HeaderView section: "dashboard"
      @view = new DashboardView

      $("#yield").addClass("container")
        .append(@header.render().el)
        .append(@view.render().el)
