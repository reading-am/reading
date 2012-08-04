reading.define [
  "backbone"
  "handlebars"
  "app/views/comments/popover"
], (Backbone, Handlebars, CommentPopover) ->

  class ShowView extends Backbone.View
    template: Handlebars.compile "<iframe id=\"page_frame\" src=\"{{page.url}}\"></iframe>"

    initialize: ->
      @frame_buster_buster()

    render: ->
      @popover = new CommentPopover model: @model
      @popover.close = => window.location = @$("iframe").attr("src")
      @popover.delegateEvents()

      @$el.html(@template(@model.toJSON()))
      @$el.prepend(@popover.render().el)

      return this

    # http://stackoverflow.com/questions/958997/frame-buster-buster-buster-code-needed
    frame_buster_buster: ->
      prevent_bust = 0  
      window.onbeforeunload = ->
        prevent_bust++
        return
      setInterval ->
        if prevent_bust > 0
          prevent_bust -= 2
          window.top.location = '/support/204'
      , 1
