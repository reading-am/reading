define [
  "underscore"
  "app/constants"
  "libs/backbone"
  "pusher"
], (_, Constants, Backbone, pusher) ->

  Backbone.Collection::endpoint = -> "#{@type.toLowerCase()}"
  Backbone.Collection::url = -> "//#{Constants.domain}/api/#{@endpoint()}"
  Backbone.Collection::channel_name = -> @endpoint().replace(/\//g,".")

  Backbone.Collection::parse = (response) ->
    # don't factory collection API responses
    # they'll get factoried in model.parse
    if response[@type.toLowerCase()]? then response[@type.toLowerCase()] else response

  Backbone.Collection::monitor = ->
    @bind "reset add", _.once =>
      @channel = pusher.subscribe @channel_name()

      @channel.bind "create", (data) =>
        @add Backbone.Model::factory data

      @channel.bind "destroy", (data) =>
        @remove Backbone.Model::factory data

  Backbone.Collection::search = (query) ->
    collection = new this.constructor

    collection.query = query

    collection._url = collection.url
    collection.url = -> "#{@_url()}/search?q=#{@query}"

    return collection

  return Backbone
