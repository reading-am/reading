class ø.Models.Page extends ø.Backbone.Model
  type: "Page"

  initialize: ->
    @has_many "Users"
    @has_many "Comments"

class ø.Collections.Pages extends ø.Backbone.Collection
  type: "Pages"
  model: ø.Models.Page
