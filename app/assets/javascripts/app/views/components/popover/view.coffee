define [
  "underscore"
  "jquery"
  "backbone"
  "text!app/views/components/popover/template.mustache"
  "text!app/views/components/popover/styles.css"
], (_, $, Backbone, template, css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class Popover extends Backbone.View
    @parse_template template

    events:
      "click .r_blocker" : "close"

    initialize: ->
      load_css()

    close: ->
      $("body > .r_disabled").removeClass "r_disabled"
      @$el.remove()
      false

    render: ->
      json = if @model? then @model.toJSON() else {}
      @$el.html(@template(json))
      $("body > *").addClass "r_disabled"
      @$el.appendTo("body")

      return this
