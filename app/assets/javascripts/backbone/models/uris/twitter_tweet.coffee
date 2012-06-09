reading.define "app/models/uris/twitter_tweet", [
  "jquery"
  "app"
  "app/models/uri"
], ($, App, URI) ->

  class TwitterTweet extends URI
    type: "TwitterTweet"
    regex: /twitter\.com\/.+\/status\/([0-9]+)/

    sync: (method, model, options) ->
      options.dataType = "jsonp"
      options.url = "https://api.twitter.com/1/statuses/show/#{@id}.json"
      $.ajax options

  App.Models.URIs.TwitterTweet = TwitterTweet
  return TwitterTweet
