define [
  "jquery"
  "backbone"
  "text!app/views/components/loading_collection/template.mustache"
  "text!app/views/components/loading_collection/styles.css"
], ($, Backbone, template, styles) ->

  class LoadingCollectionView extends Backbone.View
    @assets
      styles: styles
      template: template

    initialize: (options) ->
      @play()

    play: ->
      $s = @$el.find("span")
      t = $s.text()
      unless @interval
        @interval = setInterval ->
          t = if t.length >= 3 then "." else "#{t}."
          $s.text(t)
        , 500
      return this

    stop: ->
      @interval = clearInterval @interval
      return this

    render: ->
      @$el.html(@template())
      @play()
      return this
