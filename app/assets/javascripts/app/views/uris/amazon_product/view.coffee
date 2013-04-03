define [
  "jquery"
  "app/views/uris/uri/view"
  "app/init"
  "text!app/views/uris/amazon_product/template.mustache"
], ($, URIView, App, template) ->

  class AmazonProductView extends URIView
    @parse_template template

    render: ->
      @$el.html(@template(@model.toJSON()))

      # because some amazon images don't work with our url scheme
      # we swap them back out with links if a 1x1 image loads
      @$("img").load ->
        $this = $(this)
        if $this.width() is 1 and $this.height() is 1
          $parent = $this.parent()
          $parent.html $parent.attr("href")
          $parent.removeClass "r_uri r_amazon_product"

      return this


  App.Views.URIs.AmazonProduct = AmazonProductView
  return AmazonProductView
