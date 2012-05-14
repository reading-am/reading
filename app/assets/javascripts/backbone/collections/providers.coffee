define ["backbone","backbone/models/provider"], (Backbone, Provider) ->

  class Providers extends Backbone.Collection
    type: "Providers"
    model: Provider
