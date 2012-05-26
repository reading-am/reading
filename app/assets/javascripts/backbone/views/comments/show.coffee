define [
  "backbone"
  "handlebars"
  "app/views/comments/popover"
], (Backbone, Handlebars, CommentPopover) ->

  class ShowView extends Backbone.View
    template: Handlebars.compile "<iframe id=\"page_frame\" src=\"{{page.url}}\"></iframe>"

    render: ->
      @$el.html(@template(@model.toJSON()))
      @popover = new CommentPopover model: @model
      @$el.prepend(@popover.render().el)
      return this
