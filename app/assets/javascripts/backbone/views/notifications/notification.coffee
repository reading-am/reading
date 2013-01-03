define [
  "jquery"
  "backbone"
  "handlebars"
  "text!app/templates/notifications/notification.hbs"
], ($, Backbone, Handlebars, template) ->

  class NotificationView extends Backbone.View

    id: "r_am"
    tagName: 'div'
    template: Handlebars.compile template

    events:
      "click .r_close" : "close"

    initialize: ->
      # if the page has a frameset, create a body and reload the page in an iframe
      $frameset = $("frameset")
      if $frameset.length
        $iframe = $("<iframe>").attr(
          id: "r_iframe"
          src: window.location.href
        ).load =>
          $frameset.remove()
          $body.show()
          @render()

        $body = $("<body>").attr(id: "r_body").hide().append $iframe
        $("html").append $body

      else
        @render()

    render: ->
      @$el.html(@template(@model))
      @$el.appendTo("body").fadeIn 500
      cb = => @close()
      setTimeout cb, 5000
          

    close: ->
      console.log "close!!!"
      @$el.fadeOut 400, =>
        @$el.remove()
      false