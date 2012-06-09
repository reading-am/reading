reading.define "app/models/uris/vimeo_video", [
  "jquery"
  "app"
  "app/models/uri"
], ($, App, URI) ->

  class VimeoVideo extends URI
    type: "VimeoVideo"
    regex: /vimeo\.com\/([0-9]+)/

    sync: (method, model, options) ->
      return # disabled at the moment
      options.dataType = "jsonp"
      options.url = "https://vimeo.com/api/v2/video/#{@id}.json"

      _success = if options.success? then options.success else _.log
      options.success = (data, textStatus, jqXHR) ->
        _success data[0], textStatus, jqXHR

      $.ajax options

  App.Models.URIs.VimeoVideo = VimeoVideo
  return VimeoVideo
