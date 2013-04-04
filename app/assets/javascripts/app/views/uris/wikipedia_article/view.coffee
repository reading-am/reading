define [
  "underscore"
  "jquery"
  "app/views/uris/uri/view"
  "app/init"
  "text!app/views/uris/wikipedia_article/template.mustache"
  "text!app/views/uris/wikipedia_article/styles.css"
], (_, $, URIView, App, template, css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class WikipediaArticleView extends URIView
    @parse_template template

    initialize: (options) ->
      load_css()
      super options

  App.Views.URIs.WikipediaArticle = WikipediaArticleView
  return WikipediaArticleView
