define [
  "jquery"
  "backbone"
  "handlebars"
  "app/views/components/popover"
  "text!app/templates/users/popover.hbs"
  "text!users/popover.css"
], ($, Backbone, Handlebars, Popover, template, css) ->
	
  $("<style>").html(css).appendTo("head")

  class UserPopover extends Popover

    template: Handlebars.compile template

    id: "r_user_popover"
