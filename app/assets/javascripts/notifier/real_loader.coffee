#= require baseUrl
require [
  "jquery"
  "app/views/notifications/notification"
  "pusher"
  "text!notifications/notifications.css"
], ($, Notification, pusher, css) ->

  $("<style>").html(css).appendTo("head")


  # Eventually I'll swap this out with the pusher listener
  # Right now I'm keeping it fixed while I work on the visual stuff
  

  channel = pusher.subscribe("comments")
  channel.bind 'create', (data) ->
    console.log '----------------------------------------------'
    console.log data
    model =
      username: data.user.username
      action: "commented on"
      page: data.page.title
      page_url: data.page.url
    new Notification(model: model)
