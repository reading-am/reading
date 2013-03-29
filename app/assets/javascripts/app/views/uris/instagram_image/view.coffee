define [
  "app/views/uris/uri/view"
  "mustache"
  "app/init"
  "text!app/views/uris/instagram_image/template.mustache"
], (URIView, Mustache, App, template) ->

  class InstagramImageView extends URIView
    template: Mustache.compile template

    className: "r_url r_uri r_instagram_image"

  App.Views.URIs.InstagramImage = InstagramImageView
  return InstagramImageView
