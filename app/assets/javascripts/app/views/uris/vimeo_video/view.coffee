define [
  "app/views/uris/uri/view"
  "app/init"
  "text!app/views/uris/vimeo_video/template.mustache"
], (URIView, App, template) ->

  class VimeoVideoView extends URIView
    @parse_template template
    attributes: {}

  App.Views.URIs.VimeoVideo = VimeoVideoView
  return VimeoVideoView
