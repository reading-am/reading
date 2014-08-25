define [
  "underscore"
  "app/views/base/collection/view"
], (_, CollectionView) ->

  class GroupedCollectionView extends CollectionView
    groupBy: ""
    groupUnder: ""
    groupView: {}
    groupCollection: {}

    initialize: (options={}) ->
      @groupBy          = options.groupBy if options.groupBy?
      @groupUnder       = options.groupUnder if options.groupUnder?
      @groupView        = options.groupView if options.groupView?
      @groupCollection  = options.groupCollection if options.groupCollection?

      sub_props =
        el: options.el
        collection: new @groupCollection
        attributes: _.extend @groupView.attributes, @attributes

      # Assign the HTML template props that @assets asigns on the parent
      for prop in ["id", "className"]
        sub_props[prop] = @[prop] if @[prop]
      if @tagName.toLowerCase() isnt "div"
        sub_props.tagName = @tagName

      @subview = new @groupView sub_props
      @setElement @subview.el

      # call super before the reset
      super
      # make this silent so it doesn't render automatically
      @reset @collection, silent: true

      # When models are added to a subgroup collection, go back
      # and add them to the master collection. This prevents things like
      # adding a post to a subgroup collection and then it getting readded
      # by Pusher to the master collection and trickling back down to the
      # subcollection again.
      @subview.collection.each @bind_bubble
      @subview.collection.on "add", @bind_bubble, this
      @subview.collection.on "reset", => @subview.collection.each @bind_bubble

    bind_bubble: (model) =>
      model[@groupUnder].on "add", (model) => @collection.add(model)

    group: (model, collection, options) ->
      gb = model.get @groupBy
      if existing = collection.get gb
        if @groupUnder then existing[@groupUnder].add(model, options)
      else
        if @groupUnder then gb[@groupUnder].add(model, options)
        collection.add gb, options

    reset: (collection, options) ->
      tmp_collection = new @groupCollection
      collection.each (model) => @group(model, tmp_collection, options)
      @subview.collection.reset(tmp_collection.models, options)

    add: (model, collection, options) ->
      delete options.remove # setOptions defaults remove to true
      @group model, @subview.collection, options

    attach_status: (collection=@collection) ->
      @subview.attach_status collection
      return this

    infinite_scroll: (collection=@collection) ->
      @subview.infinite_scroll collection
      return this

    progressive_render: ->
      @subview.progressive_render()
      return this

    render: ->
      @subview.render()
      return this
