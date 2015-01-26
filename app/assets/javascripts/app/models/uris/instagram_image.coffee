define [
  "jquery"
  "app/init"
  "app/models/uris/uri"
], ($, App, URI) ->

  class InstagramImage extends URI
    type: "InstagramImage"
    regex: /instagr\.?am(?:\.com)?\/p\/([^\/]+)/

    sync: (method, model, options) ->
      options.dataType = "jsonp"
      options.url = "https://api.instagram.com/oembed?url=http://instagram.com/p/#{@id}/"
      $.ajax options

  App.Models.URIs.InstagramImage = InstagramImage
  return InstagramImage
