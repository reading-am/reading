define ["backbone"], (Backbone) ->

  class Page extends Backbone.Model
    type: "Page"

    initialize: ->
      @has_many "Users"
      @has_many "Comments"
