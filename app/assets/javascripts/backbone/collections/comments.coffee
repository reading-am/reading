define [
  "backbone"
  "app/init"
  "app/models/comment"
], (Backbone, App, Comment) ->

  class App.Collections.Comments extends Backbone.Collection
    type: "Comments"
    model: Comment

    comparator: (comment) -> comment.get("id")

    initialize: ->
      @monitor()
