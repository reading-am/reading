define [
  "app/views/uris/uri/view"
  "app/init"
  "text!app/views/uris/twitter_tweet/template.mustache"
  "text!app/views/uris/twitter_tweet/styles.css"
], (URIView, App, template, styles) ->

  class TwitterTweetView extends URIView
    @assets
      styles: styles
      template: template

  App.Views.URIs.TwitterTweet = TwitterTweetView
  return TwitterTweetView
