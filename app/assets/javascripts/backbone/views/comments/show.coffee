define [
  "backbone"
  "mustache"
  "app/views/comments/popover"
  "text!app/templates/comments/show.mustache"
], (Backbone, Mustache, CommentPopover, template) ->

  class ShowView extends Backbone.View
    template: Mustache.compile template

    render: ->
      @popover = new CommentPopover model: @model
      @popover.close = => window.location = @$("iframe").attr("src")
      @popover.delegateEvents()

      @$el.html(@template(@model.toJSON()))
      @$el.prepend(@popover.render().el)

      return this
