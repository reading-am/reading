define [
  "backbone"
  "text!app/views/admin/header/template.mustache"
], (Backbone, template) ->

  class AdminHeaderView extends Backbone.View
    @parse_template template

    initialize: (options) ->
      @section = options.section

    render: ->
      json = {}
      json[@section] = true if @section
      @$el.html @template(json)

      return this
