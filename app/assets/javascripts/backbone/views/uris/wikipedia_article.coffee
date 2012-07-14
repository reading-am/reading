define [
  "app/views/uris/uri"
  "handlebars"
  "app/init"
], (URIView, Handlebars, App) ->

  class WikipediaArticleView extends URIView
    template: Handlebars.compile "
    {{#if id}}
      <h3 class=\"r_wikipedia_article_title\"><img src=\"https://wikipedia.org/favicon.ico\" class=\"r_icon\"> {{title}}</h3>
      <div class=\"r_wikipedia_article_extract\">{{{short_extract}}}</div>
    {{else}}
      Loading Wikipedia Article...
    {{/if}}
    "

    className: "r_url r_uri r_wikipedia_article"

  App.Views.URIs.WikipediaArticle = WikipediaArticleView
  return WikipediaArticleView
