define [
  "underscore"
  "jquery"
  "backbone"
  "mustache"
  "app/views/components/popover/view"
  "text!app/views/users/popover/template.mustache"
  "text!app/views/users/popover/styles.css"
], (_, $, Backbone, Mustache, Popover, template, css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class UserPopover extends Popover

    template: Mustache.compile template

    id: "r_user_popover"

    initialize: ->
      load_css()
      super()
