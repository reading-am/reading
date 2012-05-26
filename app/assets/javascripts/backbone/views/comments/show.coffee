define [
  "backbone"
  "handlebars"
], (Backbone, Handlebars) ->

  class ShowView extends Backbone.View
    template: Handlebars.compile "<iframe id=\"page_frame\" src=\"{{page.url}}\"></iframe>"

    render: ->
      $(@el).html(@template(@model.toJSON()))
      return this
