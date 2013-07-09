define [
  "app/views/base/collection"
], (CollectionView) ->

  class GroupedCollectionView extends CollectionView
    group_by: ""
    group_under: ""
    group_view: {}
    group_collection: {}

    initialize: (options) ->
      @subview = new @group_view collection: new @group_collection
      @addAll @collection
      @setElement @subview.el
      super options

    group: (model, collection) ->
      existing = collection.get(model.get(@group_by).id)
      if existing
        existing[@group_under].add model
      else
        model.get(@group_by)[@group_under].add model
        collection.add(model.get(@group_by))

    addAll: (collection, options) ->
      tmp_collection = new @group_collection
      collection.each (model) => @group(model, tmp_collection)
      @subview.collection.reset tmp_collection.models

    addOne: (model, collection, options, bulk) ->
      @group model, @subview.collection

    render: ->
      @subview.render()
      return this
