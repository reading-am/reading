reading.define "app/views/providers/providers", [
  "backbone"
  "app/views/providers/provider"
], (Backbone, ProviderView) ->

  class ProvidersView extends Backbone.View
    tagName: "ul"

    initialize: ->
      @collection.bind "reset", @addAll

    addAll: =>
      @collection.each(@addOne)

    addOne: (provider) =>
      view = new ProviderView({model : provider})
      @$el.append(view.render().el)

    render: =>
      @addAll()
      return this
