define [
  "app/views/components/popover/view"
  "text!app/views/users/popover/template.mustache"
  "text!app/views/users/popover/styles.css"
], (Popover, template, styles) ->

  class UserPopover extends Popover
    @assets
      styles: styles
      template: template
