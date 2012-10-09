define [
  "backbone"
], (Backbone) ->

  class CollectionView extends Backbone.View
    tagName: "ul"

    initialize: (options) ->
      @collection.on "reset", @addAll
      @collection.on "add", @addOne

    addAll: =>
      @collection.each @addOne

    addOne: (model) =>
      props = model: model
      props.tagName = "li" if @tagName is "ul" or @tagName is "ol"
      props.size = @size if @size?

      view = new @modelView props

      i = @collection.indexOf(model)
      c_len = @$el.children().length

      # debugging
      #console.log model.type, @collection.indexOf(model), i, c_len, @collection.length, model.get("id"), model

      # add models in order if we're only adding one of them
      if c_len is @collection.length-1 and i < c_len
        @$el.children().eq(i).before(view.render().el)
      else
        @$el.append(view.render().el)

    render: =>
      @addAll()
      return this
