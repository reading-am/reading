define [
  "backbone"
  "app/views/comments/overlay/view"
  "text!app/views/comments/show/template.mustache"
], (Backbone, CommentOverlay, template) ->

  class ShowView extends Backbone.View
    @assets
      template: template

    render: ->
      @overlay = new CommentOverlay model: @model
      @overlay.close = => window.location = @$("iframe").attr("src")
      @overlay.delegateEvents()

      @$el.html(@template(@model.toJSON()))
      @$el.prepend(@overlay.render().el)

      return this
