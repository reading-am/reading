define [
  "backbone"
  "text!app/views/posts/medium_selector/template.mustache"
  "text!app/views/posts/medium_selector/styles.css"
], (Backbone, template, styles) ->

  class MediumSelectorView extends Backbone.View 
    @assets
      styles: styles
      template: template
