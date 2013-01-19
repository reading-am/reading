define [
  "underscore"
  "jquery"
  "backbone"
  "handlebars"
  "text!app/templates/components/popover.hbs"
  "text!components/popover.css"
], (_, $, Backbone, Handlebars, template, css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class Popover extends Backbone.View
    template: Handlebars.compile template

    className: "r_popover"

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
      @$el.prependTo("body")

      return this
