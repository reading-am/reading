define [
  "backbone"
  "handlebars"
  "text!app/templates/admin/header.hbs"
], (Backbone, Handlebars, template) ->

  class AdminHeaderView extends Backbone.View
    template: Handlebars.compile template

    initialize: (options) ->
      @section = options.section

    render: ->
      json = {}
      json[@section] = true if @section
      @$el.html @template(json)

      return this
