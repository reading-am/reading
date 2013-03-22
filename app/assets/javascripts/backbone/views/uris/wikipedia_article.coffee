define [
  "app/views/uris/uri"
  "mustache"
  "app/init"
  "text!app/templates/uris/wikipedia_article.mustache"
], (URIView, Mustache, App, template) ->

  class WikipediaArticleView extends URIView
    template: Mustache.compile template

    className: "r_url r_uri r_wikipedia_article"

  App.Views.URIs.WikipediaArticle = WikipediaArticleView
  return WikipediaArticleView
