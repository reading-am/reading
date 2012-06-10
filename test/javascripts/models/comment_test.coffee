#= require curl_config
#= require libs/curl
#= require ./shared_helper

reading.curl [
  "app/models/comment"
], (Comment) ->

  describe "Model", ->
    describe "Comment", ->

      beforeEach ->
        @model = new Comment id: 200

      shared()
