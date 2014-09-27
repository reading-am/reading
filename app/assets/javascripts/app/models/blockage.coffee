define [
  "backbone"
  "app/init"
], (Backbone, App) ->

  class Blockage extends Backbone.Model
    type: "Blockage"

  App.Models.Blockage = Blockage
  return Blockage
