define [
  "underscore"
  "jquery"
  "app/views/uris/uri/view"
  "app/init"
  "text!app/views/uris/youtube_video/template.mustache"
  "text!app/views/uris/youtube_video/styles.css"
], (_, $, URIView, App, template, css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class YouTubeVideoView extends URIView
    @parse_template template
    attributes: {}

    initialize: (options) ->
      load_css()
      super options

  App.Views.URIs.YouTubeVideo = YouTubeVideoView
  return YouTubeVideoView
