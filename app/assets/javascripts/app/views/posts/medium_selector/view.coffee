define [
  "app/views/components/selector/view"
  "text!app/views/posts/medium_selector/template.mustache"
  "text!app/views/posts/medium_selector/styles.css"
], (SelectorView, template, styles) ->

  class MediumSelectorView extends SelectorView
    @assets
      styles: styles
      template: template

    json: ->
      j = {}
      j["medium_#{@start_val}"] = true
      return j
