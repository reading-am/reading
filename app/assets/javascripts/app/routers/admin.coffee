define [
  "jquery"
  "backbone"
  "app/views/admin/header/view"
  "app/views/admin/dashboard/view"
], ($, Backbone, HeaderView, DashboardView) ->

  class AdminRouter extends Backbone.Router

    routes:
      "admin/dashboard" : "dashboard"

    dashboard: (id) ->
      @header = new HeaderView section: "dashboard"
      @view = new DashboardView

      $("body").attr(id: "dashboard_view")
      @$yield.addClass("container")
        .append(@header.render().el)
        .append(@view.render().el)
