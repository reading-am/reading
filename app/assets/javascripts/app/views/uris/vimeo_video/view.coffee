define [
  "app/views/uris/uri/view"
  "mustache"
  "app/init"
  "text!app/views/uris/vimeo_video/template.mustache"
], (URIView, Mustache, App, template) ->

  class VimeoVideoView extends URIView
    template: Mustache.compile template

    tagName: "div"
    className: "r_url r_uri r_vimeo_video"
    attributes: {}

  App.Views.URIs.VimeoVideo = VimeoVideoView
  return VimeoVideoView
