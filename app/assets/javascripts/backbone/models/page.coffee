define [
  "backbone"
  "app"
  "app/collections/users"
  "app/collections/comments"
], (Backbone, App) ->

  class App.Models.Page extends Backbone.Model
    type: "Page"

    initialize: ->
      @has_many "Users"
      @has_many "Comments"
