define [
  "backbone"
  "handlebars"
  "css!components/popover"
], (Backbone, Handlebars) ->

  class Popover extends Backbone.View
    template: Handlebars.compile "<div class=\"r_blocker\"></div>"

    className: "r_popover"

    events:
      "click" : "close"

    close: ->
      @$el.remove()
