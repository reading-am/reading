#= require curl_config
#= require libs/curl
#= require ./shared

reading.curl [
  "test/collections/shared"
  "app/collections/comments"
], (shared, Comments) ->

  describe "Collection", ->
    describe "Comments", ->

      beforeEach ->
        @collection = new Comments

      shared()
