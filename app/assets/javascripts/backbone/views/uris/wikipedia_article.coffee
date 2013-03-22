define [
  "app/views/uris/uri"
  "mustache"
  "app/init"
  "text!app/templates/uris/wikipedia_article.hbs"
], (URIView, Handlebars, App, template) ->

  class WikipediaArticleView extends URIView
    template: Handlebars.compile template

    className: "r_url r_uri r_wikipedia_article"

  App.Views.URIs.WikipediaArticle = WikipediaArticleView
  return WikipediaArticleView
