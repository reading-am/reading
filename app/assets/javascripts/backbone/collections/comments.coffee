define ["backbone","app/models/comment"], (Backbone, Comment) ->

  class Comments extends Backbone.Collection
    type: "Comments"
    model: Comment

    comparator: (comment) -> comment.get("id")

    initialize: ->
      @poll "id", 5
