#= require curl_config
#= require libs/curl
#= require ./shared

reading.curl [
  "test/models/shared"
  "app/models/post"
], (shared, Post) ->

  describe "Model", ->
    describe "Post", ->

      beforeEach ->
        @model = new Post id: 200

      shared()
