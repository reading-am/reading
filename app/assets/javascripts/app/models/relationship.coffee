define [
  "backbone"
  "app/init"
], (Backbone, App) ->

  class Relationship extends Backbone.Model
    type: "Relationship"

    params: ->
      user_ids: [@get("subject").id]

    endpoint: ->
      "users/#{@get("enactor").id}/following#{
        if @isNew() then "" else "/#{@get("subject").id}"
      }"

  App.Models.Relationship = Relationship
  return Relationship
