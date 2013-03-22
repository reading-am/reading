define [
  "app/views/uris/uri"
  "mustache"
  "app/init"
  "text!app/templates/uris/twitter_tweet.mustache"
], (URIView, Handlebars, App, template) ->

  class TwitterTweetView extends URIView
    template: Handlebars.compile template

    className: "r_url r_uri r_twitter_tweet"

  App.Views.URIs.TwitterTweet = TwitterTweetView
  return TwitterTweetView
