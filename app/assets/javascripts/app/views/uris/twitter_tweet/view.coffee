define [
  "app/views/uris/uri/view"
  "app/init"
  "text!app/views/uris/twitter_tweet/template.mustache"
], (URIView, App, template) ->

  class TwitterTweetView extends URIView
    @parse_template template

  App.Views.URIs.TwitterTweet = TwitterTweetView
  return TwitterTweetView
