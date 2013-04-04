define [
  "underscore"
  "jquery"
  "app/views/uris/uri/view"
  "app/init"
  "text!app/views/uris/twitter_tweet/template.mustache"
  "text!app/views/uris/twitter_tweet/styles.css"
], (_, $, URIView, App, template, css) ->
  load_css = _.once(=>$("<style>").html(css).appendTo("head"))

  class TwitterTweetView extends URIView
    @parse_template template

    initialize: (options) ->
      load_css()
      super options

  App.Views.URIs.TwitterTweet = TwitterTweetView
  return TwitterTweetView
