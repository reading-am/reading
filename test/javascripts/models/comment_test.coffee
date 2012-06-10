#= require curl_config
#= require libs/curl
#= require ./shared

reading.curl [
  "test/models/shared"
  "app/models/comment"
], (shared, Comment) ->

  describe "Model", ->
    describe "Comment", ->

      beforeEach ->
        @model = new Comment id: 200

      shared()
