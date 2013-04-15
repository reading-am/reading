define [
  "app/views/uris/uri/view"
  "app/init"
  "text!app/views/uris/wikipedia_article/template.mustache"
  "text!app/views/uris/wikipedia_article/styles.css"
], (URIView, App, template, styles) ->

  class WikipediaArticleView extends URIView
    @assets
      styles: styles
      template: template

  App.Views.URIs.WikipediaArticle = WikipediaArticleView
  return WikipediaArticleView
