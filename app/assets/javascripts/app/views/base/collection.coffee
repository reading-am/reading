define [
  "jquery"
  "backbone"
], ($, Backbone) ->

  class CollectionView extends Backbone.View
    tagName: "ul"
    animate: true

    initialize: (options) ->
      @collection.on "reset", @addAll, this
      @collection.on "add", @addOne, this

      @modelView = options.modelView if options.modelView?

    addAll: (collection, options) ->
      # Insert the elements off the DOM
      $tmp_el = $("<div>")
      @collection.each (model) => @addOne model, collection, options, $tmp_el, true
      @$el.html($tmp_el.contents())

    addOne: (model, collection, options, $el=@$el, bulk) ->
      props = model: model
      props.tagName = "li" if @tagName is "ul" or @tagName is "ol"

      view = new @modelView props
      view.render()
      view.$el.hide() unless !@animate || bulk

      i = @collection.indexOf(model)
      c_len = $el.children().length

      # debugging
      #console.log model.type, @collection.indexOf(model), i, c_len, @collection.length, model.get("id"), model

      # add models in order if we're only adding one of them
      if c_len is @collection.length-1 and i < c_len
        $el.children().eq(i).before(view.el)
      else
        $el.append(view.el)

      view.$el.slideDown() unless !@animate || bulk

    render: ->
      @addAll()
      return this
