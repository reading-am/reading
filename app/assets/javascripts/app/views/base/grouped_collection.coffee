define [
  "app/views/base/collection"
], (CollectionView) ->

  class GroupedCollectionView extends CollectionView
    groupBy: ""
    groupUnder: ""
    groupView: {}
    groupCollection: {}

    initialize: (options) ->
      @subview = new @groupView collection: new @groupCollection
      @addAll @collection, silent: true # make this silent so it doesn't render automatically
      @setElement @subview.el
      super options

    group: (model, collection, options) ->
      existing = collection.get(model.get(@groupBy).id)
      if existing
        existing[@groupUnder].add(model, options)
      else
        model.get(@groupBy)[@groupUnder].add(model, options)
        collection.add(model.get(@groupBy), options)

    addAll: (collection, options) ->
      tmp_collection = new @groupCollection
      collection.each (model) => @group(model, tmp_collection, options)
      @subview.collection.reset(tmp_collection.models, options)

    addOne: (model, collection, options, bulk) ->
      @group model, @subview.collection, options

    render: ->
      @subview.render()
      return this
