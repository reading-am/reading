define [
  "backbone"
  "app/views/comments/overlay/view"
  "text!app/views/comments/show/styles.css"
  "text!app/views/comments/show/template.mustache"
], (Backbone, CommentOverlayView, styles, template) ->

  class ShowView extends Backbone.View
    @assets
      styles: styles
      template: template

    json: ->
      j = @model.toJSON()
      j.page = @model.get("page").toJSON()
      return j

    render: ->
      @overlay = new CommentOverlayView model: @model
      @overlay.close = => window.location = @$("iframe").attr("src")
      @overlay.delegateEvents()

      @$el.html(@template(@json()))
      @$el.prepend(@overlay.render().el)

      return this
