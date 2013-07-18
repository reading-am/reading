define [
  "underscore"
  "app/constants"
  "libs/backbone"
  "pusher"
], (_, Constants, Backbone, pusher) ->

  Backbone.Collection::endpoint = -> "#{@type.toLowerCase()}"
  Backbone.Collection::params = {limit:50, offset:0}
  Backbone.Collection::url = -> "//#{Constants.domain}/api/#{_.result @,"endpoint"}"
  Backbone.Collection::channel_name = -> @endpoint().replace(/\//g,".")

  Backbone.Collection::parse = (response) ->
    # don't factory collection API responses
    # they'll get factoried in model.parse
    if response[@type.toLowerCase()]? then response[@type.toLowerCase()] else response

  Backbone.Collection::monitor = ->
    # Do nothing on duplicate calls
    return if @channel?.name is @channel_name()
    # Disconnect if we're switching channels
    @channel?.disconnect()

    @channel = pusher.subscribe @channel_name()

    @channel.bind "create", (data) =>
      # since we're using optimistic creation of models,
      # there might already be an item in the collection from this user
      # that doesn't yet have an id from the POST response. Remove it1
      # TODO replace this with http://pusher.com/docs/server_api_guide/server_excluding_recipients
      no_id = @find (obj) -> !obj.id?
      if no_id? and data.user?.id? and no_id.get("user")?.id? and no_id.get("user").id is data.user.id
        @remove no_id

      @add Backbone.Model::factory data

    @channel.bind "update", (data) =>
      obj = Backbone.Model::factory data
      @get(obj.id).set(obj.attributes)

    @channel.bind "destroy", (data) =>
      @remove Backbone.Model::factory data

    return this

  Backbone.Collection::search = (query) ->
    collection = new this.constructor

    collection._url = collection.url
    collection.url = -> "#{_.result @,"_url"}/search"
    collection.params.q = query

    return collection

  Backbone.Collection::fetchNextPage = (options={}) ->
    @params.offset += @params.limit
    options.remove = false
    @fetch options

  return Backbone
