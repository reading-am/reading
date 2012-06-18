# Needed by Firefox for auto parsing of JSON from CORS requests
# from: http://api.jquery.com/jQuery.ajax/

reading.define [
  "jquery"
], ($) ->

  _super = $.ajaxSettings.xhr
  $.ajaxSettings.xhr = ->
      xhr = _super()
      getAllResponseHeaders = xhr.getAllResponseHeaders

      xhr.getAllResponseHeaders = ->
        return getAllResponseHeaders() if getAllResponseHeaders()

        allHeaders = ""

        $([
          "Cache-Control"
          "Content-Language"
          "Content-Type"
          "Expires"
          "Last-Modified"
          "Pragma"
        ]).each (i, header_name) ->
          if xhr.getResponseHeader(header_name)
            allHeaders += "#{header_name}: #{xhr.getResponseHeader(header_name)}\n"

          return allHeaders

      return xhr

  return $
