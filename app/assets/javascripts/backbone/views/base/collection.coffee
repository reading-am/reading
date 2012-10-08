define [
  "backbone"
], (Backbone) ->

  class CollectionView extends Backbone.View
    sort: "asc"

    tagName: "ul"

    initialize: ->
      @collection.bind "reset", @addAll
      @collection.bind "add", @addOne

    addAll: =>
      @collection.each @addOne

    addOne: (model) =>
      if @sort.toLowerCase() is "asc"
        before_after = "before"
        append_prepend = "append"
      else
        before_after = "after"
        append_prepend = "prepend"

      view = new @modelView model:model

      i = @collection.length-1 - @collection.indexOf(model)
      li_len = @$("li").length

      # add models in order if we're only adding one of them
      # TODO - this math might be wrong for asc, haven't tested
      if li_len is @collection.length-1 and i
        @$("li:eq(#{i-1})")[before_after](view.render().el)
      else
        @$el[append_prepend](view.render().el)

    render: =>
      @addAll()
      return this
