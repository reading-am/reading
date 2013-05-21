define [
  "jquery"
  "backbone"
  "text!app/views/components/overlay/template.mustache"
  "text!app/views/components/overlay/styles.css"
], ($, Backbone, template, styles) ->

  # NOTE - this is called an Overlay rather than a Popover
  # because AdBlock blocks the loading of any JS files with
  # "popover" in their path

  class Overlay extends Backbone.View
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
