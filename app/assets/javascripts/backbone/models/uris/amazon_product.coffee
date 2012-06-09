reading.define [
  "app"
  "app/models/uri"
], (App, URI) ->

  class AmazonProduct extends URI
    type: "AmazonProduct"
    regex: /amazon\.[A-Za-z\.]+(?:\/.+)?\/..(?:\/product)?\/([^\/]+)/

    initialize: (options) ->
      # image path hacked from: http://aaugh.com/imageabuse.html
      @set "id", @regex.exec(options.string)[1]
      @set "image", "http://ec2.images-amazon.com/images/P/#{@get("id")}.01._SCMZZZZZZZ_.jpg"

    sync: (method, model, options) ->
      # amazon doesn't presently have a jsonp API
      # possible option: https://github.com/christianhellsten/amazon-json-api
      return

  App.Models.URIs.AmazonProduct = AmazonProduct
  return AmazonProduct
