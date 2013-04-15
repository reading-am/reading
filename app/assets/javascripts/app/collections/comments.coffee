define [
  "backbone"
  "app/init"
  "app/models/comment"
], (Backbone, App, Comment) ->

  class App.Collections.Comments extends Backbone.Collection
    type: "Comments"
    model: Comment

    comparator: (comment) ->
      if comment.get("id")?
        id = comment.get("id")
      else if @first().get("id")?
        id = @first().get("id")+1
      else
        # 999... is a hack so that the first new comment
        # without an id will appear at the top
        id = 9999999999

      return -id
