define [
  "jquery"
  "backbone"
], ($, Backbone) ->

  class CollectionView extends Backbone.View
    tagName: "ul"
    animate: true

    initialize: (options) ->
      @collection.on "reset", @addAll, this
      @collection.on "add", @add, this

      @modelView = options.modelView if options.modelView?

    addAll: (collection, options) ->
      # Insert the elements off the DOM
      $tmp_el = $("<div>")
      @collection.each (model) => @add model, collection, options, $tmp_el
      @$el.html($tmp_el.contents())

    add: (model, collection, options, $el=@$el) ->
      props = model: model
      props.tagName = "li" if @tagName is "ul" or @tagName is "ol"

      i = @collection.indexOf(model)
      c_len = $el.children().length
      bulk = c_len < @collection.length-1

      view = new @modelView props
      view.render()
      view.$el.hide() unless !@animate || bulk

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
