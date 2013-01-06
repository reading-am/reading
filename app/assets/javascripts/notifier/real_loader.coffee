#= require baseUrl
require [
  "jquery"
  "app/views/notifications/notification"
  "pusher"
  "text!notifications/notifications.css"
], ($, Notification, pusher, css) ->

  $("<style>").html(css).appendTo("head")  

  channel = pusher.subscribe("comments")
  channel.bind 'notify', (data) ->
    model =
      username: data.user.username
      action: "commented on"
      page: data.page.title
      page_url: data.page.url
    new Notification(model: model)
