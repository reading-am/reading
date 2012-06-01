reading.define [
  "backbone"
  "handlebars"
  "css!components/popover"
], (Backbone, Handlebars) ->

  class Popover extends Backbone.View
    template: Handlebars.compile "<div class=\"r_blocker\"></div>"

    className: "r_popover"

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
      @$el.prependTo("body")

      return this
