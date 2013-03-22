define [
  "app/views/uris/uri"
  "mustache"
  "app/init"
  "text!app/templates/uris/instagram_image.mustache"
], (URIView, Mustache, App, template) ->

  class InstagramImageView extends URIView
    template: Mustache.compile template

    className: "r_url r_uri r_instagram_image"

  App.Views.URIs.InstagramImage = InstagramImageView
  return InstagramImageView
