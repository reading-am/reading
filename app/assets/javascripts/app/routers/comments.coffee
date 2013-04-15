define [
  "jquery"
  "backbone"
  "app/models/comment"
  "app/views/comments/show/view"
], ($, Backbone, Comment, ShowView) ->

  class CommentsRouter extends Backbone.Router
    initialize: (options) ->
      if options.model?
        @model = new Comment options.model

    routes:
      ":username/comments/:id" : "show"

    show: (id) ->
      @view = new ShowView model: @model
      $("#yield").html @view.render().el
