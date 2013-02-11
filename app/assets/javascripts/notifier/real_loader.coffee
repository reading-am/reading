#= require baseUrl
require [
  "jquery"
  "app/views/notifications/notification"
  "pusher"
  "text!notifications/notifications.css"
  "app/constants"
], ($, Notification, pusher, css, Constants) ->

  subscribe = (id) ->
    channel = pusher.subscribe("users.#{id}.notifications")
    channel.bind "create", (data) ->

      model =
        username: data.user.username
        action: "commented on"
        page: data.page.title
        page_url: data.page.url

      new Notification(model: model)

  $("<style>").html(css).appendTo("head")
  
  if 'localStorage' in window and window['localStorage'] is not null
    u = JSON.parse(localStorage.getItem("reading:user")) 

  if u
    subscribe u.id 
  else
    $.ajax
      url: "http://#{Constants.domain}/api/me"
      xhrFields:
        withCredentials: true
      success: (data) ->
        localStorage.setItem("reading:user", JSON.stringify(data)) if data
        subscribe data.id
