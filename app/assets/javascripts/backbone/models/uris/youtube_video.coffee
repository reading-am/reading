reading.define "app/models/uris/youtube_video", [
  "jquery"
  "app"
  "app/models/uri"
], ($, App, URI) ->

  class YouTubeVideo extends URI
    type: "YouTubeVideo"
    regex: /youtube\.com\/watch.*(?:\?|&)v=([A-Za-z0-9]+)/

    sync: (method, model, options) ->
      return # disabled at the moment
      options.dataType = "jsonp"
      options.url = "https://gdata.youtube.com/feeds/api/videos/#{@id}?v=2&alt=json"
      $.ajax options

  App.Models.URIs.YouTubeVideo = YouTubeVideo
  return YouTubeVideo
