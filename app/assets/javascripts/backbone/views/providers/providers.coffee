ø.Views.Providers ||= {}

class ø.Views.Providers.ProvidersView extends ø.Backbone.View
  tagName: "ul"

  initialize: ->
      @collection.bind "reset", @addAll

    addAll: =>
      @collection.each(@addOne)

    addOne: (provider) =>
      view = new ø.Views.Providers.ProviderView({model : provider})
      @$el.append(view.render().el)

    render: =>
      @addAll()
      return this
