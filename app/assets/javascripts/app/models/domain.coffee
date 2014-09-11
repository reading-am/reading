define [
  "jquery"
  "backbone"
  "app/init"
], ($, Backbone, App) ->

  class Domain extends Backbone.Model
    type: "Domain"

    initialize: ->
      @has_many "Pages"
      @has_many "Posts"

  App.Models.Domain = Domain
  return Domain
