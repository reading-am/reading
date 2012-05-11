class ø.Models.Comment extends ø.Backbone.Model
  type: "Comment"
  validate: (attr) ->
    if !attr.body || (!attr.page and !attr.page_id)
      return errors.general

class ø.Collections.Comments extends ø.Backbone.Collection
  type: "Comments"
  model: ø.Models.Comment

  comparator: (comment) -> comment.get("id")

  initialize: ->
    @poll "id", 5
