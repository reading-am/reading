define [
  "backbone"
  "app"
  "app/constants"
], (Backbone, App, Constants) ->

  class Comment extends Backbone.Model
    type: "Comment"
    validate: (attr) ->
      if !attr.body || (!attr.page and !attr.page_id)
        return Constants.errors.general

  App.Models.Comment = Comment
  return Comment
