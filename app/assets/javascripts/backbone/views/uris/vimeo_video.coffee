reading.define "app/views/uris/vimeo_video", [
  "app/views/uris/uri"
  "handlebars"
  "app"
], (URIView, Handlebars, App) ->

  class VimeoVideoView extends URIView
    template: Handlebars.compile "
      <iframe src=\"http://player.vimeo.com/video/{{id}}\" frameborder=\"0\" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>
    "

    tagName: "div"
    className: "r_url r_uri r_vimeo_video"
    attributes: {}

  App.Views.URIs.VimeoVideo = VimeoVideoView
  return VimeoVideoView
