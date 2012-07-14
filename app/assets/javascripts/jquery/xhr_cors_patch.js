define(["jquery"], function ($) {

  // workaround for Firefox CORS bug - see http://bugs.jquery.com/ticket/10338#comment:14

  var _super = $.ajaxSettings.xhr;
  $.ajaxSetup({
    xhr: function() {
      var xhr = _super();
      var getAllResponseHeaders = xhr.getAllResponseHeaders;
      xhr.getAllResponseHeaders = function() {
        var allHeaders = getAllResponseHeaders.call(xhr);
        if (allHeaders) {
          return allHeaders;
        }
        allHeaders = "";
        var concatHeader = function(i, header_name) {
          if (xhr.getResponseHeader(header_name)) {
            allHeaders += header_name + ": " + xhr.getResponseHeader( header_name ) + "\n";
          }
        };
        // simple headers (fixed set)
        $(["Cache-Control", "Content-Language", "Content-Type", "Expires", "Last-Modified", "Pragma"]).each(concatHeader);
        // non-simple headers (add more as required)
        $(["Location"] ).each(concatHeader);
        return allHeaders;
      };
      return xhr;
    }
  });

});
