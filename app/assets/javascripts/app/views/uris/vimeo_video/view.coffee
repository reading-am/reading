define [
  "app/views/uris/uri/view"
  "app/init"
  "text!app/views/uris/vimeo_video/template.mustache"
  "text!app/views/uris/vimeo_video/styles.css"
], (URIView, App, template, styles) ->

  class VimeoVideoView extends URIView
    @assets
      styles: styles
      template: template
      
    attributes: {}

  App.Views.URIs.VimeoVideo = VimeoVideoView
  return VimeoVideoView
