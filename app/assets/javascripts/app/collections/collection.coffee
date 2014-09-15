define [
  "underscore"
  "app/constants"
  "libs/backbone"
  "pusher"
], (_, Constants, Backbone, pusher) ->

  Backbone.Collection::endpoint = -> _.result @, "urlName"

  default_limit = 50
  Backbone.Collection::params = {limit:default_limit, offset:0}
  Backbone.Collection::reset_paging = ->
    @params.limit = default_limit
    @params.offset = 0

  Backbone.Collection::_fetch = Backbone.Collection::fetch
  Backbone.Collection::fetch = (options) ->
    @reset_paging() if options?.reset
    @_fetch options

  Backbone.Collection::parse = (response) ->
    # don't factory collection API responses
    # they'll get factoried in model.parse
    prop = _.result(@model, "urlRoot") || @type.toLowerCase()
    if response[prop]? then response[prop] else response

  Backbone.Collection::getEach = (objs) ->
    objs = [objs] unless _.isArray objs
    result = []
    _.each objs, (o) => if o = @get(o) then result.push(o)
    result

  Backbone.Collection::setEach = (objs, key, val, options) ->
    _.each @getEach(objs), (o) -> o.set key, val, options

  Backbone.Collection::monitor = ->
    # Do nothing on duplicate calls
    return if @channel?.name is @channel_name()
    # Disconnect if we're switching channels
    @channel?.disconnect()

    @channel = pusher.subscribe @channel_name()

    @channel.bind "create", (data) =>
      # Since we're using optimistic creation of models,
      # there might already be an item in the collection from this user
      # that doesn't yet have an id from the POST response. If so,
      # don't add anything. TODO: consider replacing this with http://pusher.com/docs/server_api_guide/server_excluding_recipients
      no_id = @find (obj) -> !obj.id?
      unless no_id? and data.user?.id? and no_id.get("user")?.id? and no_id.get("user").id is data.user.id
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

  Backbone.Collection::fetchNRecords = (n, options={}) ->
    @fetchNPages Math.ceil(n/@params.limit), options

  Backbone.Collection::fetchNPages = (n, options={}) ->
    i = 0
    if options.success
      _success = options.success
      options.success = -> _success.apply(this, arguments) if --i is 0
    if options.error
      _error = options.error
      options.error = ->
        if i >= 0
          i = -1 # prevents success and other errors from calling
          _error.apply(this, arguments)

    if @length is 0
      @fetch options
      i++
    while i < n
      i++
      @fetchNextPage options

  return Backbone
