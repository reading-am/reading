define [
  "jquery"
  "app/init"
  "app/constants"
  "app/models/uris/uri"
], ($, App, Constants, URI) ->

  class VimeoVideo extends URI
    type: "VimeoVideo"
    regex: /vimeo\.com\/([0-9]+)/

    sync: (method, model, options) ->
      return if Constants.env is "production" # disabled at the moment
      options.dataType = "jsonp"
      options.url = "https://vimeo.com/api/v2/video/#{@id}.json"

      $.ajax options

    parse: (response) ->
      return response[0]

  App.Models.URIs.VimeoVideo = VimeoVideo
  return VimeoVideo
