define ["backbone","app/models/provider"], (Backbone, Provider) ->

  class Providers extends Backbone.Collection
    type: "Providers"
    model: Provider
