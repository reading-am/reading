define [
  "app/views/components/selector/view"
  "text!app/views/posts/medium_selector/template.mustache"
], (SelectorView, template) ->

  class MediumSelectorView extends SelectorView
    @assets
      template: template

    json: ->
      j = {}
      j["medium_#{@start_val}"] = true
      return j
