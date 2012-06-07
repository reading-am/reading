reading.define [
  "app/views/uris/uri"
  "handlebars"
  "app"
], (URIView, Handlebars, App) ->

  class TweetView extends URIView
    template: Handlebars.compile "
    {{#if text}}
      {{text}}
    {{else}}
      Tweet goes here
    {{/if}}
    "

    className: "r_url r_tweet"

  App.Views.URIs.Tweet = TweetView
  return TweetView
