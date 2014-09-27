define [
  "backbone"
  "app/init"
], (Backbone, App) ->

  class Blockage extends Backbone.Model
    type: "Blockage"

    endpoint: ->
      "users/#{@get("blocker").id}/blocking#{
        if @isNew() then "" else "/#{@get("blocked").id}"
      }"

  App.Models.Blockage = Blockage
  return Blockage
