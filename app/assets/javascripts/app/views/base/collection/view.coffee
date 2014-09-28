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
    animation: (view) -> view.$el.slideDown()

    initialize: (options) ->
      @collection.on "sync",  @sync,  this
      @collection.on "reset", @reset, this
      @collection.on "add",   @add,   this

      @modelView = options.modelView if options.modelView?
      @attach_status()

    reset: (collection, options) ->
      # Insert the elements off the DOM for faster rendering
      $tmp_el = $("<div>")
      @collection.each (model) => @add model, collection, options, $tmp_el
      $tmp_el.append @status_view.el if @status_view
      @$el.html($tmp_el.contents())

    num_rendered: ($el=@$el) ->
      $el.children().not(".r_status").length

    add: (model, collection, options, $el=@$el) ->
      props = model: model
      tag = @tagName.toLowerCase()
      props.tagName = "li" if tag is "ul" or tag is "ol"

      i = @collection.indexOf(model)
      c_len = @num_rendered($el)
      bulk = c_len < @collection.length-1

      view = new @modelView props
      view.render()
      view.$el.hide() unless !@animation || bulk

      if i < c_len # prepending somewhere in the stack
        $el.children().eq(i).before(view.el)
      else if $el.find("> .r_status").length
        $el.find("> .r_status").before(view.el)
      else
        $el.append(view.el)

      @animation view unless !@animation || bulk

    attach_status: (collection=@collection) ->
      if @status_view then @status_view.remove()

      props =
        el: @$(".r_status")[0]
        collection: collection
        loading_msg: @loading_msg
        empty_msg: @empty_msg
      props.tagName = "li" if @tagName is "ul" or @tagName is "ol"
      @status_view = new CollectionStatusView props

      @status_view.render()
      return this

    infinite_scroll: (collection=@collection) ->
      if collection.length >= collection.params.limit
        @$el.waypoint
          handler: (direction) =>
            if direction is "down" and @num_rendered() >= @collection.length
              @$el.waypoint "disable"
              collection.fetchNextPage success: (collection, data) =>
                # This is on a delay because the waypoints plugin will miscalculate
                # the offset if rendering the new DOM elements hasn't finished
                more = !!data?[collection.type.toLowerCase()]?.length
                setTimeout =>
                  @$el.waypoint(if more then "enable" else "destroy")
                , 1500
          offset: "bottom-in-view"

      return this

    progressive_render: (collection=@collection) ->
      set_wp = =>
        @$el.waypoint
          handler: (direction) =>
            n = @num_rendered()
            if direction is "down" and n < collection.length
              @add collection.at(n)
            setTimeout set_wp, 100
          offset: ->
            vh = $.waypoints('viewportHeight')
            vh - $(this).outerHeight() + vh/2
          triggerOnce: true

      collection.off "add", @add
      collection.on "add", (model, collection) =>
        # If it is being added to the end, render it
        if collection.indexOf(model) < @num_rendered()-1
          @add model

      collection.off "reset", @reset
      collection.on "reset", =>
        @$el.html("")
        set_wp()

      return this

    render: ->
      @reset @collection
      return this
