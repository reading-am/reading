define [
  "app/views/uris/uri"
  "mustache"
  "app/init"
  "text!app/templates/uris/youtube_video.mustache"
], (URIView, Mustache, App, template) ->

  class YouTubeVideoView extends URIView
    template: Mustache.compile template

    tagName: "div"
    className: "r_url r_uri r_youtube_video"
    attributes: {}

  App.Views.URIs.YouTubeVideo = YouTubeVideoView
  return YouTubeVideoView
