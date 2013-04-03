define [
  "app/views/uris/uri/view"
  "app/init"
  "text!app/views/uris/wikipedia_article/template.mustache"
], (URIView, App, template) ->

  class WikipediaArticleView extends URIView
    @parse_template template

  App.Views.URIs.WikipediaArticle = WikipediaArticleView
  return WikipediaArticleView
