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
      @addAll @collection
      @setElement @subview.el
      super options

    group: (model, collection) ->
      existing = collection.get(model.get(@groupBy).id)
      if existing
        existing[@groupUnder].add model
      else
        model.get(@groupBy)[@groupUnder].add model
        collection.add(model.get(@groupBy))

    addAll: (collection, options) ->
      tmp_collection = new @groupCollection
      collection.each (model) => @group(model, tmp_collection)
      @subview.collection.reset tmp_collection.models

    addOne: (model, collection, options, bulk) ->
      @group model, @subview.collection

    render: ->
      @subview.render()
      return this
