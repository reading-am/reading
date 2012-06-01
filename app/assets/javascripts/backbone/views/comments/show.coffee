reading.define [
  "backbone"
  "handlebars"
  "app/views/comments/popover"
], (Backbone, Handlebars, CommentPopover) ->

  class ShowView extends Backbone.View
    template: Handlebars.compile "<iframe id=\"page_frame\" src=\"{{page.url}}\"></iframe>"

    render: ->
      @popover = new CommentPopover model: @model
      @popover.close = => window.location = @$("iframe").attr("src")
      @popover.delegateEvents()

      @$el.html(@template(@model.toJSON()))
      @$el.prepend(@popover.render().el)

      return this
