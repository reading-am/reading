define [
  "app/views/uris/uri/view"
  "app/init"
  "text!app/views/uris/youtube_video/template.mustache"
  "text!app/views/uris/youtube_video/styles.css"
], (URIView, App, template, styles) ->

  class YouTubeVideoView extends URIView
    @assets
      styles: styles
      template: template
      
    attributes: {}

  App.Views.URIs.YouTubeVideo = YouTubeVideoView
  return YouTubeVideoView
