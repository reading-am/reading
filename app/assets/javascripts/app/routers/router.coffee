define [
  "underscore"
  "jquery"
  "libs/backbone"
  "app/constants"
], (_, $, Backbone, Constants) ->

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

  # In testing, create a sniff test for whether or not Backbone
  # has finised its rendering
  # if Constants.env is "test"
  Backbone.Router::execute = (callback, args, name) ->
    @executed = false
    callback.apply(this, args) if (callback)
    @executed = true


  return Backbone
