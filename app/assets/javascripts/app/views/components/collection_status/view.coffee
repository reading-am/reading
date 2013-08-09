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
      @collection.on "request", @request, this
      @collection.on "sync",    @sync,    this
      @collection.on "reset",   @sync,    this

      # If already visible, animate the ellipsis
      @loading() if @$(".r_loading").is(":visible")

    request: ->
      @loading()

    sync: (collection) ->
      @complete()
      @empty() if collection.length is 0

    empty: ->
      @$(".r_empty").show()
      @$(".r_loading").hide()
      return this

    loading: ->
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

    render: ->
      @$el.html(@template())
      return this
