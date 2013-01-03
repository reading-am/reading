#= require baseUrl
require [
  "jquery"
  "app/views/notifications/notification"
  "pusher"
  "text!components/notifications.css"
], ($, Notification, pusher, css) ->

  $("<style>").html(css.join " ").appendTo("head")

  model =
    username: "@davidbyrd11"
    action: "commented on"
    page: "Google"
    page_url: "http://www.google.com"
  n = new Notification(model: model)
  n.render()