define [
  "app/init"
  "app/constants"
  "app/models/uris/uri"
], (App, Constants, URI) ->

  class AmazonProduct extends URI
    type: "AmazonProduct"
    regex: /amazon\.[A-Za-z\.]+(?:\/.+)?\/..(?:\/product)?\/([^\/?]+)/

    initialize: (options) ->
      super

      # image path hacked from: http://aaugh.com/imageabuse.html
      @set "image", "http://ec2.images-amazon.com/images/P/#{@get("id")}.01._SCMZZZZZZZ_.jpg"

      # from: http://stackoverflow.com/questions/7640270/adding-modify-query-string-get-variables-in-a-url-with-javascript
      add_param = (url, param, value) ->
        val = new RegExp "(\\?|\\&)#{param}=.*?(?=(&|$))"
        if val.test(url)
          url.replace(val, "$1#{param}=#{value}")
        else if /\?.+$/.test(url)
          "#{url}&#{param}=#{value}"
        else
          "#{url}?#{param}=#{value}"

      @set "string", add_param(options.string, "tag", Constants.amazon_assoc_id)

    sync: (method, model, options) ->
      # amazon doesn't presently have a jsonp API
      # possible option: https://github.com/christianhellsten/amazon-json-api
      return

  App.Models.URIs.AmazonProduct = AmazonProduct
  return AmazonProduct
