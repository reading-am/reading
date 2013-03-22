define [
  "underscore"
  "jquery"
  "backbone"
  "mustache"
  "app/views/components/popover"
  "text!app/templates/users/popover.mustache"
  "text!users/popover.css"
], (_, $, Backbone, Handlebars, Popover, template, css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class UserPopover extends Popover

    template: Handlebars.compile template

    id: "r_user_popover"

    initialize: ->
      load_css()
      super()
