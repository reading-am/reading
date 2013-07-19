define [
  "backbone"
  "text!app/views/posts/medium_selector/template.mustache"
  "text!app/views/posts/medium_selector/styles.css"
], (Backbone, template, styles) ->

  class MediumSelectorView extends Backbone.View
    @assets
      styles: styles
      template: template

    initialize: (options) ->
      @$("select").val options.start_val
      @on_change = options.on_change

    events:
      "change select" : "changed"

    changed: (e) ->
      @on_change @$(e.target).attr("value")
