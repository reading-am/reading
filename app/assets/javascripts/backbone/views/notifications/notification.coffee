define [
  "jquery"
  "backbone"
  "handlebars"
  "text!app/templates/notifications/notification.hbs"
], ($, ModelView, Handlebars, template) ->

  class NotificationView extends Backbone.View
    el: $("r_notification")
    template: Handlebars.compile template
    render: ->
      @template(@model)

