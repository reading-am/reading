define [
  "jquery"
  "backbone"
  "handlebars"
  "app/views/components/popover"
  "text!users/popover.css"
], ($, Backbone, Handlebars, Popover, css) ->
	
  $("<style>").html(css).appendTo("head")

  class UserPopover extends Popover

    template: Handlebars.compile "
      <div class=\"r_blocker\"></div>
      <iframe class=\"r_content\" src=\"{{url}}\"></iframe>
    "

    id: "r_user_popover"
