define [
  "app/views/uris/uri/view"
  "app/init"
  "text!app/views/uris/instagram_image/template.mustache"
], (URIView, App, template) ->

  class InstagramImageView extends URIView
    @parse_template template

  App.Views.URIs.InstagramImage = InstagramImageView
  return InstagramImageView
