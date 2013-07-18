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
      @router = options.router
      @username = options.username
      @$("select").val options.medium || "all"

    events:
      "change select" : "change_medium"

    change_medium: (e) ->
      url = "#{@username}/list"
      medium = @$(e.target).attr("value")
      url += "/#{medium}" unless medium is "all"
      @router.navigate url, trigger: true
