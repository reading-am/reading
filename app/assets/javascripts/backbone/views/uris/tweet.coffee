reading.define [
  "app/views/uris/uri"
  "handlebars"
  "app"
], (URIView, Handlebars, App) ->

  class TweetView extends URIView
    template: Handlebars.compile "
    {{#if text}}
      <div class=\"r_tweet_text\">{{text}}</div>
      <div class=\"r_tweet_info\">
        <img class=\"r_icon\" src=\"https://twitter.com/favicon.ico\">
        <span class=\"r_tweet_name\">{{user.name}}</span>
        (@<a src=\"https://twitter.com/{{user.screen_name}}\" class=\"r_tweet_screen_name\">{{user.screen_name}}</a>)
      </div>
    {{else}}
      Loading Tweet...
    {{/if}}
    "

    className: "r_url r_uri r_tweet"

  App.Views.URIs.Tweet = TweetView
  return TweetView
