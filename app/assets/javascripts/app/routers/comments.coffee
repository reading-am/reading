define [
  "jquery"
  "backbone"
  "app/views/comments/show/view"
], ($, Backbone, CommentShowView) ->

  class CommentsRouter extends Backbone.Router

    routes:
      ":username/comments/:id" : "show"

    show: (id) ->
      @view = new CommentShowView model: @model
      @$yield.html @view.render().el
