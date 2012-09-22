define [
  "underscore"
  "app/constants"
  "libs/backbone"
], (_, Constants, Backbone) ->

  Backbone.Collection::url = -> "//#{Constants.domain}/api/#{@type.toLowerCase()}"

  Backbone.Collection::parse = (response) ->
    # don't factory collection API responses
    # they'll get factoried in model.parse
    if response[@type.toLowerCase()]? then response[@type.toLowerCase()] else response

  Backbone.Collection::poll = (attr, secs) ->
    polling = false
    @bind "reset add", _.once =>
      @_url = @url
      @url = => "#{_.result(this, "_url")}?after_#{attr}=#{if @length > 0 then encodeURIComponent @last().toJSON()[attr] else ''}"
      @intervals "add", secs, =>
        if !polling
          polling = true
          @fetch
            add: true
            success: -> polling = false

  Backbone.Collection::search = (query) ->
    collection = new this.constructor

    collection.query = query

    collection._url = collection.url
    collection.url = -> "#{@_url()}/search?q=#{@query}"

    return collection

  return Backbone
