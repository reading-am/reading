define [
  "jquery"
  "backbone"
  "text!app/views/components/popover/template.mustache"
  "text!app/views/components/popover/styles.css"
], ($, Backbone, template, styles) ->

  class Popover extends Backbone.View
    @assets
      styles: styles
      template: template

    events:
      "click .r_blocker" : "close"

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
