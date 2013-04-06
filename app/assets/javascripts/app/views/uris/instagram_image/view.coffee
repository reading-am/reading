define [
  "app/views/uris/uri/view"
  "app/init"
  "text!app/views/uris/instagram_image/template.mustache"
  "text!app/views/uris/instagram_image/styles.css"
], (URIView, App, template, styles) ->

  class InstagramImageView extends URIView
    @assets
      styles: styles
      template: template

  App.Views.URIs.InstagramImage = InstagramImageView
  return InstagramImageView
