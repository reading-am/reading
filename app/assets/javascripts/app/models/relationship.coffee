define [
  "backbone"
  "app/init"
], (Backbone, App) ->

  class Relationship extends Backbone.Model
    type: "Relationship"

    endpoint: ->
      "users/#{@get("follower").id}/following#{
        if @isNew() then "" else "/#{@get("followed").id}"
      }"

  App.Models.Relationship = Relationship
  return Relationship
