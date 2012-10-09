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
      li_len = @$("li").length

      # debugging
      #console.log model.type, @collection.indexOf(model), i, li_len, @collection.length, model.get("id"), model

      # add models in order if we're only adding one of them
      if li_len is @collection.length-1 and i < li_len
        @$("li:eq(#{i})").before(view.render().el)
      else
        @$el.append(view.render().el)

    render: =>
      @addAll()
      return this
