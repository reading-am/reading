reading.define [
  "backbone"
  "handlebars"
  "app/views/components/popover"
  "css!users/popover"
], (Backbone, Handlebars, Popover) ->

  class UserPopover extends Popover

    template: Handlebars.compile "
      <div class=\"r_blocker\"></div>
      <iframe class=\"r_content\" src=\"{{url}}\"></iframe>
    "

    id: "r_user_popover"
