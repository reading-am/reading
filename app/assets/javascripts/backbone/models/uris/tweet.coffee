reading.define [
  "jquery"
  "app"
  "app/models/uri"
], ($, App, URI) ->

  class Tweet extends URI
    type: "Tweet"
    regex: /twitter\.com\/.+\/status\/([0-9]+)/

    sync: (method, model, options) ->
      options.dataType = "jsonp"
      options.url = "https://api.twitter.com/1/statuses/show/#{@id}.json"
      $.ajax options

  App.Models.URIs.Tweet = Tweet
  return Tweet
