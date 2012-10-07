define [
  "jquery"
  "backbone"
  "handlebars"
  "text!app/templates/admin/dashboard.hbs"
  "text!admin/dashboard.css"
], ($, Backbone, Handlebars, template, css) ->

  $("<style>").html(css).appendTo("head")

  class DashboardView extends Backbone.View
    template: Handlebars.compile template

    render: ->
      @$el.html(@template())

      @$(".total").each (i, el) =>
        type = el.id.split("_")[1]
        $.ajax("/api/#{type}/count").done (msg) ->
          $(el).html msg[el.id]

      return this
