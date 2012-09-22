define [
  "jquery"
  "app/init"
  "app/models/uris/uri"
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
