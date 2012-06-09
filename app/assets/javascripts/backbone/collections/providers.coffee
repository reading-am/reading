reading.define "app/collections/providers", [
  "backbone"
  "app"
  "app/models/provider"
], (Backbone, App, Provider) ->

  class App.Collections.Providers extends Backbone.Collection
    type: "Providers"
    model: Provider
