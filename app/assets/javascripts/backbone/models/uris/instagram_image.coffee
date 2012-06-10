reading.define [
  "jquery"
  "app"
  "app/models/uris/uri"
], ($, App, URI) ->

  class InstagramImage extends URI
    type: "InstagramImage"
    regex: /instagr\.am\/p\/([^\/]+)/

    sync: (method, model, options) ->
      options.dataType = "jsonp"
      options.url = "https://api.instagram.com/oembed?url=http://instagr.am/p/#{@id}/"
      $.ajax options

  App.Models.URIs.InstagramImage = InstagramImage
  return InstagramImage
