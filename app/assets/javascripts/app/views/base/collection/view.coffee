define [
  "jquery"
  "backbone"
  "app/views/components/collection_status/view"
  "text!app/views/base/collection/styles.css"
  "extend/jquery/waypoints"
], ($, Backbone, CollectionStatusView, styles) ->

  class CollectionView extends Backbone.View
    @assets
      styles: styles

    tagName: "ul"
    animate: true

    initialize: (options) ->
      @collection.on "sync",  @sync,  this
      @collection.on "reset", @reset, this
      @collection.on "add",   @add,   this

      @modelView = options.modelView if options.modelView?
      @attach_status()

    reset: (collection, options) ->
      if collection.length
        # Insert the elements off the DOM for faster rendering
        $tmp_el = $("<div>")
        @collection.each (model) => @add model, collection, options, $tmp_el
        $tmp_el.append @status_view.el if @status_view

        @$el.html($tmp_el.contents())

    add: (model, collection, options, $el=@$el) ->
      props = model: model
      tag = @tagName.toLowerCase()
      props.tagName = "li" if tag is "ul" or tag is "ol"

      i = @collection.indexOf(model)
      c_len = $el.children().not(".r_status").length
      bulk = c_len < @collection.length-1

      view = new @modelView props
      view.render()
      view.$el.hide() unless !@animate || bulk

      # add models in order if we're only adding one of them
      if c_len is @collection.length-1 and i < c_len
        $el.children().eq(i).before(view.el)
      else if $el.find("> .r_status").length
        $el.find("> .r_status").before(view.el)
      else
        $el.append(view.el)

      view.$el.slideDown() unless !@animate || bulk

    attach_status: ->
      if !@status_view
        props =
          el: @$(".r_status")[0]
          collection: @status_collection ? @collection
        props.tagName = "li" if @tagName is "ul" or @tagName is "ol"
        @status_view = new CollectionStatusView props

      return this

    infinite_scroll: ->
      @$el.waypoint "destroy" # reset any existing waypoint

      if @collection.length >= @collection.params.limit
        @$el.waypoint (direction) =>
          if direction is "down"
            @$el.waypoint "disable"
            @collection.fetchNextPage success: (collection, data) =>
              # This is on a delay because the waypoints plugin will miscalculate
              # the offset if rendering the new DOM elements hasn't finished
              more = data?[collection.type.toLowerCase()]?.length >= collection.params.limit
              setTimeout =>
                @$el.waypoint(if more then "enable" else "destroy")
              , 1500
        , {offset: "bottom-in-view"}

      return this

    render: ->
      @$el.append @status_view.render().el if @status_view
      @reset @collection
      return this
