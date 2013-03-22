define [
  "app/views/uris/uri"
  "mustache"
  "app/init"
  "text!app/templates/uris/vimeo_video.mustache"
], (URIView, Handlebars, App, template) ->

  class VimeoVideoView extends URIView
    template: Handlebars.compile template

    tagName: "div"
    className: "r_url r_uri r_vimeo_video"
    attributes: {}

  App.Views.URIs.VimeoVideo = VimeoVideoView
  return VimeoVideoView
