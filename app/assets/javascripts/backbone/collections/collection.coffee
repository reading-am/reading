define [
  "underscore",
  "libs/backbone"
], (_, Backbone) ->

  Backbone.Collection::parse = (response) ->
    # don't factory collection API responses
    # they'll get factoried in model.parse
    response.response[@type.toLowerCase()]

  Backbone.Collection::poll = (attr, secs) ->
    polling = false
    @bind "reset add", _.once =>
      @_url = @url
      @url = => "#{_.result(this, "_url")}?after_#{attr}=#{encodeURIComponent @last().toJSON()[attr]}"
      @intervals "add", secs, =>
        if !polling
          polling = true
          @fetch
            add: true
            success: -> polling = false

  return Backbone
