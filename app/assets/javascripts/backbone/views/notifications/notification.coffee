define [
  "jquery"
  "backbone"
  "handlebars"
  "text!app/templates/notifications/notification.hbs"
], ($, Backbone, Handlebars, template) ->

  class NotificationView extends Backbone.View

    className: "r_notification"
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

      # Toggle page title with notification.
      count = 0
      title = document.title
      username = @model.username
      interval = setInterval ->
        mod = count % 2
        if mod == 0
          document.title = username + ' mentioned you'
        else
          document.title = title

        if ++count == 6
          clearInterval interval
          @close()
      , 1000

      closeNotification = => @close()

    close: ->
      @$el.fadeOut 400, =>
        @$el.remove()