define [
  "underscore"
  "jquery"
  "libs/backbone"
], (_, $, Backbone) ->

  Backbone.Router::query_params = ->
    # via: http://stackoverflow.com/questions/901115/how-can-i-get-query-string-values
    params = {}
    pl     = /\+/g  # Regex for replacing addition symbol with a space
    search = /([^&=]+)=?([^&]*)/g
    decode = (s) -> decodeURIComponent(s.replace(pl, " "))
    query  = window.location.search.substring(1)

    while (match = search.exec(query))
       params[decode(match[1])] = decode(match[2])

    return params

  Backbone.Router::initialize = (options) ->
    @$yield = $("#yield")

    if options?.model?
      @model = options.model
    if options?.collection?
      @collection = options.collection

  return Backbone
