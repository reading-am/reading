define [
  "backbone"
], (Backbone) ->

  class CollectionView extends Backbone.View
    tagName: "ul"
    animate: true

    initialize: (options) ->
      @collection.on "reset", @addAll, this
      @collection.on "add", @addOne, this

    addAll: (collection, options) ->
      @collection.each (model) => @addOne model, collection, options, true

    addOne: (model, collection, options, bulk) ->
      props = model: model
      props.tagName = "li" if @tagName is "ul" or @tagName is "ol"
      props.size = @size if @size?

      view = new @modelView props
      view.render()
      view.$el.hide() unless !@animate || bulk

      i = @collection.indexOf(model)
      c_len = @$el.children().length

      # debugging
      #console.log model.type, @collection.indexOf(model), i, c_len, @collection.length, model.get("id"), model

      # add models in order if we're only adding one of them
      if c_len is @collection.length-1 and i < c_len
        @$el.children().eq(i).before(view.el)
      else
        @$el.append(view.el)

      view.$el.slideDown() unless !@animate || bulk

    render: =>
      @addAll()
      return this
