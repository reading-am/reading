reading.define [
  "app/views/uris/uri"
  "handlebars"
  "app"
], (URIView, Handlebars, App) ->

  class AmazonProductView extends URIView
    template: Handlebars.compile "
    {{#if image}}
      <img src=\"{{image}}\">
    {{else}}
      Loading Amazon product...
    {{/if}}
    "

    className: "r_url r_uri r_amazon_product"

  App.Views.URIs.AmazonProduct = AmazonProductView
  return AmazonProductView
