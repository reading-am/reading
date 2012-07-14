define [
  "app/views/uris/uri"
  "handlebars"
  "app/init"
], (URIView, Handlebars, App) ->

  class YouTubeVideoView extends URIView
    template: Handlebars.compile "
      <iframe src=\"http://www.youtube.com/embed/{{id}}\" frameborder=\"0\" allowfullscreen></iframe>
    "

    tagName: "div"
    className: "r_url r_uri r_youtube_video"
    attributes: {}

  App.Views.URIs.YouTubeVideo = YouTubeVideoView
  return YouTubeVideoView
