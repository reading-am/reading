define [
  "jquery"
  "backbone"
  "text!app/views/components/collection_status/template.mustache"
  "text!app/views/components/collection_status/styles.css"
], ($, Backbone, template, styles) ->

  class CollectionStatusView extends Backbone.View
    @assets
      styles: styles
      template: template

    initialize: (options) ->
      @loading_msg = options.loading_msg
      @empty_msg = options.empty_msg

      @collection.on "request", @loading, this
      @collection.on "sync",    @sync,    this
      @collection.on "reset",   @sync,    this
      @collection.on "add",     => @sync() # don't pass the model
      @collection.on "remove",  => @sync() # don't pass the model

      # If already visible, animate the ellipsis
      @loading() if @$(".r_loading").is(":visible")

    sync: (col_or_model=@collection)->
      if col_or_model is @collection
        @complete()
        
        if @collection.length is 0
          @empty()
        else
          @not_empty()

    empty: ->
      @$(".r_empty").show()
      @$(".r_loading").hide()
      return this

    not_empty: ->
      @$(".r_empty").hide()
      @$(".r_loading").hide()
      return this

    loading: (col_or_model=@collection) ->
      # this method receives events for both the collection
      # and its containing models
      if col_or_model is @collection and (@collection.length is 0 or
      @collection.length < @collection.params.limit + @collection.params.offset)
        @$(".r_empty").hide()
        @$(".r_loading").show()

        $s = @$(".r_loading span")
        t = $s.text()
        unless @interval
          @interval = setInterval ->
            t = if t.length >= 3 then "." else "#{t}."
            $s.text(t)
          , 500

      return this

    complete: ->
      @interval = clearInterval @interval
      @$(".r_loading").hide()
      return this

    json: ->
      loading_msg: @loading_msg
      empty_msg: @empty_msg

    render: ->
      @$el.html(@template(@json()))
      @complete() if @collection.length
      return this
