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
        # since we're using optimistic creation of models,
        # there might already be an item in the collection from this user
        # that doesn't yet have an id from the POST response. Remove it1
        no_id = @find (obj) -> !obj.id?
        if no_id? and data.user?.id? and no_id.get("user")?.id? and no_id.get("user").id is data.user.id
          @remove no_id

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
