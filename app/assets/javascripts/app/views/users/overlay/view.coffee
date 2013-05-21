define [
  "app/views/components/overlay/view"
  "text!app/views/users/overlay/template.mustache"
  "text!app/views/users/overlay/styles.css"
], (Overlay, template, styles) ->

  class UserOverlay extends Overlay
    @assets
      styles: styles
      template: template
