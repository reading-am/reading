define [
  "jquery"
  "backbone"
  "handlebars"
  "app/views/components/popover"
  "css!users/popover"
], ($, Backbone, Handlebars, Popover) ->

  class UserPopover extends Popover

    template: Handlebars.compile "
      <div class=\"r_blocker\"></div>
      <iframe class=\"r_content\" src=\"{{url}}\"></iframe>
    "

    id: "r_user_popover"

    render: ->
      @$el.html(@template(@model.toJSON()))
      $("body").prepend @el
      @$el.fadeIn("fast")

      return this
