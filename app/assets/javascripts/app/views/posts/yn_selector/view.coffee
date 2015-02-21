define [
  "app/views/components/selector/view"
  "text!app/views/posts/yn_selector/template.mustache"
], (SelectorView, template) ->

  class YnSelectorView extends SelectorView
    @assets
      template: template

    json: ->
      j = {}
      j["yn_#{@start_val}"] = true
      return j
