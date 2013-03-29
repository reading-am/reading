define [
  "app/views/uris/uri/view"
  "mustache"
  "app/init"
  "text!app/views/uris/youtube_video/template.mustache"
], (URIView, Mustache, App, template) ->

  class YouTubeVideoView extends URIView
    template: Mustache.compile template

    tagName: "div"
    className: "r_url r_uri r_youtube_video"
    attributes: {}

  App.Views.URIs.YouTubeVideo = YouTubeVideoView
  return YouTubeVideoView
