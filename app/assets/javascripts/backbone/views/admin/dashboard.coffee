define [
  "backbone"
  "handlebars"
  "text!app/templates/admin/dashboard.hbs"
], (Backbone, Handlebars, template) ->

  class DashboardView extends Backbone.View
    template: Handlebars.compile template

    render: ->
      console.log "Render DashboardView"
      @$el.html(@template())

      return this
