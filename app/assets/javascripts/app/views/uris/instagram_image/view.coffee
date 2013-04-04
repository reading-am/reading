define [
  "underscore"
  "jquery"
  "app/views/uris/uri/view"
  "app/init"
  "text!app/views/uris/instagram_image/template.mustache"
  "text!app/views/uris/instagram_image/styles.css"
], (_, $, URIView, App, template, css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class InstagramImageView extends URIView
    @parse_template template

    initialize: (options) ->
      load_css()
      super options

  App.Views.URIs.InstagramImage = InstagramImageView
  return InstagramImageView
