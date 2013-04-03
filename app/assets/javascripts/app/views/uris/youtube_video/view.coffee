define [
  "app/views/uris/uri/view"
  "mustache"
  "app/init"
  "text!app/views/uris/youtube_video/template.mustache"
], (URIView, Mustache, App, template) ->

  class YouTubeVideoView extends URIView
    @parse_template template
    attributes: {}

  App.Views.URIs.YouTubeVideo = YouTubeVideoView
  return YouTubeVideoView
