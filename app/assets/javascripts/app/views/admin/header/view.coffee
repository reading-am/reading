define [
  "backbone"
  "mustache"
  "text!app/templates/admin/header/template.mustache"
], (Backbone, Mustache, template) ->

  class AdminHeaderView extends Backbone.View
    template: Mustache.compile template

    initialize: (options) ->
      @section = options.section

    render: ->
      json = {}
      json[@section] = true if @section
      @$el.html @template(json)

      return this
