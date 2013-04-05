define [
  "underscore"
  "jquery"
  "backbone"
  "app/views/components/popover/view"
  "text!app/views/users/popover/template.mustache"
  "text!app/views/users/popover/styles.css"
], (_, $, Backbone, Popover, template, css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class UserPopover extends Popover
    @parse_template template

    initialize: (options) ->
      load_css()
      super options
