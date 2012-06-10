reading.define [
  "jquery"
  "app"
  "app/constants"
  "app/models/uris/uri"
], ($, App, Constants, URI) ->

  class YouTubeVideo extends URI
    type: "YouTubeVideo"
    regex: /(?:(?:youtube\.com\/watch.*(?:\?|&)v=)|(?:youtu.be\/))([A-Za-z0-9_]+)/

    sync: (method, model, options) ->
      return if Constants.env is "production" # disabled at the moment
      options.dataType = "jsonp"
      options.url = "https://gdata.youtube.com/feeds/api/videos/#{@id}?v=2&alt=json"
      $.ajax options

  App.Models.URIs.YouTubeVideo = YouTubeVideo
  return YouTubeVideo
