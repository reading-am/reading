define [
  "app/views/uris/uri/view"
  "mustache"
  "app/init"
  "text!app/views/uris/twitter_tweet/template.mustache"
], (URIView, Mustache, App, template) ->

  class TwitterTweetView extends URIView
    template: Mustache.compile template

    className: "r_url r_uri r_twitter_tweet"

  App.Views.URIs.TwitterTweet = TwitterTweetView
  return TwitterTweetView
