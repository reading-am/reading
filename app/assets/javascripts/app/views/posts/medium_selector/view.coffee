define [
  "backbone"
  "text!app/views/posts/medium_selector/template.mustache"
  "text!app/views/posts/medium_selector/styles.css"
], (Backbone, template, styles) ->

  class MediumSelectorView extends Backbone.View
    @assets
      styles: styles
      template: template

    events:
      "change select" : "changed"

    initialize: (options) ->
      @on_change = options.on_change
      @start_val = options.start_val
      @$("select").val @start_val

    changed: (e) ->
      @on_change @$(e.target).attr("value")

    json: ->
      j = {}
      j["medium_#{@start_val}"] = true
      return j

    render: ->
      @$el.html(@template(@json()))
      return this
