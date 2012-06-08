reading.define [
  "app/views/uris/uri"
  "handlebars"
  "app"
], (URIView, Handlebars, App) ->

  class YouTubeVideoView extends URIView
    template: Handlebars.compile "
      <iframe src=\"http://www.youtube.com/embed/{{id}}\" frameborder=\"0\" allowfullscreen></iframe>
    "

    className: "r_url r_uri r_youtube_video"

  App.Views.URIs.YouTubeVideo = YouTubeVideoView
  return YouTubeVideoView
