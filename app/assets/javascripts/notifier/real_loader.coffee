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
  model =
    username: "davidbyrd11"
    action: "commented on"
    page: "Google"
    page_url: "http://www.google.com"
  n = new Notification(model: model)