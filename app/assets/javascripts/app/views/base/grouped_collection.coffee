define [
  "app/views/base/collection/view"
], (CollectionView) ->

  class GroupedCollectionView extends CollectionView
    groupBy: ""
    groupUnder: ""
    groupView: {}
    groupCollection: {}

    initialize: (options) ->
      @subview = new @groupView
        el: options.el
        collection: new @groupCollection

      @setElement @subview.el

      # call super before the reset
      super options
      # make this silent so it doesn't render automatically
      @reset @collection, silent: true 

    group: (model, collection, options) ->
      existing = collection.get(model.get(@groupBy).id)
      if existing
        existing[@groupUnder].add(model, options)
      else
        model.get(@groupBy)[@groupUnder].add(model, options)
        collection.add(model.get(@groupBy), options)

    reset: (collection, options) ->
      tmp_collection = new @groupCollection
      collection.each (model) => @group(model, tmp_collection, options)
      @subview.collection.reset(tmp_collection.models, options)

    add: (model, collection, options) ->
      @group model, @subview.collection, options

    attach_status: (collection=@collection) ->
      @subview.attach_status collection
      return this

    infinite_scroll: (collection=@collection) ->
      @subview.infinite_scroll collection
      return this

    render: ->
      @subview.render()
      return this
