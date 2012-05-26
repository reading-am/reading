define [
  "jquery"
  "backbone"
  "handlebars"
  "css!components/popover"
], ($, Backbone, Handlebars) ->

  class UserPopover extends Backbone.View

    template: Handlebars.compile "
      <div class=\"r_blocker\"></div>
      <iframe class=\"r_content\" src=\"{{url}}\"></iframe>
    "

    id: "r_user_popover"
    className: "r_popover"

    events:
      "click" : "close"

    close: ->
      @$el.remove()

    render: ->
      @$el.html(@template(@model.toJSON()))
      $("body").prepend @el
      @$el.fadeIn("fast")
